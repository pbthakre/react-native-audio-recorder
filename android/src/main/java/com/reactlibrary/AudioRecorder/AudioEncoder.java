//
//  AudioEncoder.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 03.10.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.icu.text.SimpleDateFormat;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.util.Log;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Date;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

// Encodes audio data to fit a desired format
public class AudioEncoder {
  // The class identifier
  private static final String TAG = "AudioEncoder";

  // The file mime type
  private static final String AUDIO_MIME_TYPE = "audio/mp4a-latm";

  // The log flag
  private static final boolean VERBOSE = false;

  // The muxer state
  private static final int TOTAL_NUM_TRACKS = 1;

  // The audio state
  private static long audioBytesReceived = 0;

  // The number of tracks added to the file
  private static int numTracksAdded = 0;

  // The end of stream received flag
  private boolean eosReceived = false;

  // The end of stream sent to encoder flag
  private boolean eosSentToAudioEncoder = false;

  // The queue length counter
  private int encodingServiceQueueLength = 0;

  // The stop receiving samples flag
  private boolean stopReceived = false;

  // The start time
  private long audioStartTime = 0;

  // The total number of input frames
  private int totalInputAudioFrameCount = 0;

  // The total number of output frames
  private int totalOutputAudioFrameCount = 0;

  // The file format
  private MediaFormat audioFormat;

  // The encoder/codec
  private MediaCodec audioEncoder;

  // The track index
  private TrackIndex audioTrackIndex = new TrackIndex();

  // The muxer which combines the media data
  private MediaMuxer muxer;

  // The muxer started flag
  private boolean muxerStarted;

  // The info about the buffer
  private MediaCodec.BufferInfo audioBufferInfo;

  // The service which controls the encoding
  private ExecutorService encodingService = Executors.newSingleThreadExecutor(); // re-use encodingService

  // The audio poller
  private AudioSoftwarePoller audioSoftwarePoller;

  // The destination path of the output file
  private File destinationPath;

  // The constructor
  public AudioEncoder() throws IOException {
    prepare();
  }

  // The setter for the poller
  public void setAudioSoftwarePoller(AudioSoftwarePoller audioSoftwarePoller){
    this.audioSoftwarePoller = audioSoftwarePoller;
  }

  // Initializes all the stuff for encoding
  private void prepare() throws IOException {
    // Set initial values
    audioBytesReceived = 0;
    numTracksAdded = 0;
    eosReceived = false;
    eosSentToAudioEncoder = false;
    stopReceived = false;

    // Create filename from timestamp for the new file
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
    String fileName  = dateFormat.format(new Date()) + "--rec.m4a";

    // Define the destination path/name
    destinationPath = FileUtils.createTempFileInRootAppStorage(fileName);

    // Setup buffer info object
    this.audioBufferInfo = new MediaCodec.BufferInfo();

    // Setup the media format
    this.audioFormat = new MediaFormat();
    this.audioFormat.setString(MediaFormat.KEY_MIME, AUDIO_MIME_TYPE);
    this.audioFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
    this.audioFormat.setInteger(MediaFormat.KEY_SAMPLE_RATE, 44100);
    this.audioFormat.setInteger(MediaFormat.KEY_CHANNEL_COUNT, 1);
    this.audioFormat.setInteger(MediaFormat.KEY_BIT_RATE, 128000);
    this.audioFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384);

    // Setup the encoder
    this.audioEncoder = MediaCodec.createEncoderByType(AUDIO_MIME_TYPE);
    this.audioEncoder.configure(audioFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
    this.audioEncoder.start();

    try {
      // Setup the muxer
      this.muxer = new MediaMuxer(destinationPath.getAbsolutePath(), MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
    } catch (IOException ioe) {
      throw new RuntimeException("MediaMuxer creation failed", ioe);
    }
  }

  // Stop the encoding
  public File stop() throws ExecutionException, InterruptedException {
    Future f = this.encodingService.submit(new EncoderTask(this, EncoderTaskType.FINALIZE_ENCODER));
    f.get();

    return this.destinationPath;
  }

  // Callback for stopping
  public void _stop() {
    // Set flags and log stats
    this.stopReceived = true;
    this.eosReceived = true;
    logStatistics();
  }

  // Stop the encoding (encoder and muxer)
  public void closeEncoderAndMuxer(MediaCodec encoder, MediaCodec.BufferInfo bufferInfo, TrackIndex trackIndex) {
    drainEncoder(encoder, bufferInfo, trackIndex, true);
    try {
      // Release all stuff
      encoder.stop();
      encoder.release();
      closeMuxer();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // Release the muxer
  public void closeMuxer() {
    this.muxer.stop();
    this.muxer.release();
    this.muxer = null;
    this. muxerStarted = false;
  }

  // Make encoder available
  public void offerAudioEncoder(byte[] input, long presentationTimeStampNs) {
    if (!encodingService.isShutdown()) {
      encodingService.submit(new EncoderTask(this, input, presentationTimeStampNs));
      encodingServiceQueueLength++;
    }

  }

  // Make encoder available
  private void _offerAudioEncoder(byte[] input, long presentationTimeNs) throws IOException {
    // If started yet set start time
    if (audioBytesReceived == 0) {
      audioStartTime = presentationTimeNs;
    }

    // Count the frames
    totalInputAudioFrameCount++;
    audioBytesReceived += input.length;

    // Stop signal was sent
    if (eosSentToAudioEncoder && stopReceived || input == null) {
      logStatistics();
      if (eosReceived) {
        Log.i(TAG, "EOS received in offerAudioEncoder");
        closeEncoderAndMuxer(audioEncoder, audioBufferInfo, audioTrackIndex);
        eosSentToAudioEncoder = true;
        if (!stopReceived) {
          // swap encoder
          prepare();
        } else {
          Log.i(TAG, "Stopping Encoding Service");
          encodingService.shutdown();
        }
      }
      return;
    }
    // Transfer previously encoded data to muxer
    drainEncoder(audioEncoder, audioBufferInfo, audioTrackIndex, false);

    // Send current frame data to encoder
    try {
      ByteBuffer[] inputBuffers = audioEncoder.getInputBuffers();
      int inputBufferIndex = audioEncoder.dequeueInputBuffer(-1);
      if (inputBufferIndex >= 0) {
        ByteBuffer inputBuffer = inputBuffers[inputBufferIndex];
        inputBuffer.clear();
        inputBuffer.put(input);
        if(audioSoftwarePoller != null){
          audioSoftwarePoller.recycleInputBuffer(input);
        }
        long presentationTimeUs = (presentationTimeNs - audioStartTime) / 1000;
        if (eosReceived) {
          Log.i(TAG, "EOS received in offerEncoder");
          audioEncoder.queueInputBuffer(inputBufferIndex, 0, input.length, presentationTimeUs, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
          closeEncoderAndMuxer(audioEncoder, audioBufferInfo, audioTrackIndex); // always called after video, so safe to close muxer
          eosSentToAudioEncoder = true;
          if (stopReceived) {
            Log.i(TAG, "Stopping Encoding Service");
            encodingService.shutdown();
          }
        } else {
          audioEncoder.queueInputBuffer(inputBufferIndex, 0, input.length, presentationTimeUs, 0);
        }
      }
    } catch (Throwable t) {
      Log.e(TAG, "_offerAudioEncoder exception");
      t.printStackTrace();
    }
  }

  // Extracts all pending data from the encoder and forwards it to the muxer.
  // If endOfStream is not set, this returns when there is no more data to drain.  If it
  // is set, we send EOS to the encoder, and then iterate until we see EOS on the output.
  // Calling this with endOfStream set should be done once, right before stopping the muxer.
  // We're just using the muxer to get a .mp4 file (instead of a raw H.264 stream).  We're
  // not recording audio.
  private void drainEncoder(MediaCodec encoder, MediaCodec.BufferInfo bufferInfo, TrackIndex trackIndex, boolean endOfStream) {
    final int TIMEOUT_USEC = 100;

    if (VERBOSE) {
      Log.d(TAG, "drainEncoder(" + endOfStream + ")");
    }

    ByteBuffer[] encoderOutputBuffers = encoder.getOutputBuffers();

    while (true) {
      int encoderStatus = encoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_USEC);

      if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
        // No output available yet
        if (!endOfStream) {
          break; // Out of while
        } else {
          if (VERBOSE) Log.d(TAG, "no output available, spinning to await EOS");
        }
      } else if (encoderStatus == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
        // Not expected for an encoder
        encoderOutputBuffers = encoder.getOutputBuffers();
      } else if (encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
        // Should happen before receiving buffers, and should only happen once
        if (muxerStarted) {
          throw new RuntimeException("format changed after muxer start");
        }
        MediaFormat newFormat = encoder.getOutputFormat();

        // Start the muxer
        trackIndex.index = muxer.addTrack(newFormat);
        numTracksAdded++;
        Log.d(TAG, "encoder output format changed: " + newFormat + ". Added track index: " + trackIndex.index);

        if (numTracksAdded == TOTAL_NUM_TRACKS) {
          muxer.start();
          muxerStarted = true;
          Log.i(TAG, "All tracks added. Muxer started");
        }

      } else if (encoderStatus < 0) {
        Log.w(TAG, "unexpected result from encoder.dequeueOutputBuffer: " +
            encoderStatus);
        // let's ignore it
      } else {
        ByteBuffer encodedData = encoderOutputBuffers[encoderStatus];
        if (encodedData == null) {
          throw new RuntimeException("encoderOutputBuffer " + encoderStatus + " was null");
        }

        if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0) {
          // The codec config data was pulled out and fed to the muxer when we got
          // the INFO_OUTPUT_FORMAT_CHANGED status.  Ignore it.
          if (VERBOSE) Log.d(TAG, "ignoring BUFFER_FLAG_CODEC_CONFIG");
          bufferInfo.size = 0;
        }

        if (bufferInfo.size != 0) {
          if (!muxerStarted) {
            throw new RuntimeException("muxer hasn't started");
          }

          // Adjust the ByteBuffer values to match BufferInfo
          encodedData.position(bufferInfo.offset);
          encodedData.limit(bufferInfo.offset + bufferInfo.size);
          muxer.writeSampleData(trackIndex.index, encodedData, bufferInfo);
        }

        encoder.releaseOutputBuffer(encoderStatus, false);

        if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
          if (!endOfStream) {
            Log.w(TAG, "reached end of stream unexpectedly");
          } else {
            if (VERBOSE) Log.d(TAG, "end of stream reached");
          }
          break; // out of while
        }
      }
    }
    long endTime = System.nanoTime();
  }

  // The method for logging stats
  private void logStatistics() {
    Log.i(TAG + "-Stats", "audio frames input: " + totalInputAudioFrameCount + " output: " + totalOutputAudioFrameCount);
  }

  enum EncoderTaskType {
    ENCODE_FRAME, /*SHIFT_ENCODER,*/ FINALIZE_ENCODER;
  }

  // Can't pass an int by reference in Java...
  class TrackIndex {
    int index = 0;
  }

  // The encoding thread
  private class EncoderTask implements Runnable {
    // The class identifier
    private static final String TAG = "encoderTask";

    // The initializing flag
    boolean is_initialized = false;

    // The time
    long presentationTimeNs;

    // The encoder
    private AudioEncoder encoder;

    // The type
    private EncoderTaskType type;

    // The audio data array
    private byte[] audio_data;

    // The constructor
    public EncoderTask(AudioEncoder encoder, EncoderTaskType type) {
      setEncoder(encoder);
      this.type = type;
      switch (type) {
        case FINALIZE_ENCODER:
          setFinalizeEncoderParams();
          break;
      }
    }

    // The constructor 2
    public EncoderTask(AudioEncoder encoder, byte[] audio_data, long pts) {
      setEncoder(encoder);
      setEncodeFrameParams(audio_data, pts);
    }

    // The constructor 3
    public EncoderTask(AudioEncoder encoder) {
      setEncoder(encoder);
      setFinalizeEncoderParams();
    }

    // The setter for the encoder
    private void setEncoder(AudioEncoder encoder) {
      this.encoder = encoder;
    }

    // The setter for the initialized flag
    private void setFinalizeEncoderParams() {
      is_initialized = true;
    }

    // The setter for the parameters
    private void setEncodeFrameParams(byte[] audio_data, long pts) {
      this.audio_data = audio_data;
      this.presentationTimeNs = pts;

      is_initialized = true;
      this.type = EncoderTaskType.ENCODE_FRAME;
    }

    // Encode the frames
    private void encodeFrame() throws IOException {
      if (encoder != null && audio_data != null) {
        encoder._offerAudioEncoder(audio_data, presentationTimeNs);
        audio_data = null;
      }
    }

    // Stops encoding
    private void finalizeEncoder() {
      encoder._stop();
    }

    @Override
    public void run() {
      if (is_initialized) {
        switch (type) {
          case ENCODE_FRAME:
            try {
              encodeFrame();
            } catch (IOException e) {
              e.printStackTrace();
            }
            break;
          case FINALIZE_ENCODER:
            finalizeEncoder();
            break;

        }

        // Prevent multiple execution of same task
        is_initialized = false;
        encodingServiceQueueLength -= 1;

      } else {
        Log.e(TAG, "run() called but EncoderTask not initialized");
      }
    }
  }
}