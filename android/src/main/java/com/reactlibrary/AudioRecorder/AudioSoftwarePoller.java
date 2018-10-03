//
//  AudioSoftwarePoller.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 03.10.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;

import java.util.concurrent.ArrayBlockingQueue;

/*
 * This class polls audio from the microphone and feeds an
 * AudioEncoder. Audio buffers are recycled between this class and the AudioEncoder
 *
 * Usage:
 *
 * 1. AudioSoftwarePoller recorder = new AudioSoftwarePoller();
 * 1a (optional): recorder.setSamplesPerFrame(NUM_SAMPLES_PER_CODEC_FRAME)
 * 2. recorder.setAudioEncoder(myAudioEncoder)
 * 2. recorder.startPolling();
 * 3. recorder.stopPolling();
 */
public class AudioSoftwarePoller {
  // The class identifier
  public static final String TAG = "AudioSoftwarePoller";

  // The audio file sample rate
  private static final int SAMPLE_RATE = 44100;

  // The number of channels of the audio file
  private static final int CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO;

  // The encoding of the audio file
  private static final int AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

  // The number of frames per buffer
  private static final int FRAMES_PER_BUFFER = 24; // 1 sec @ 1024 samples/frame (aac)

  // The number of microseconds per frame
  private static long US_PER_FRAME = 0;

  // The recording flag
  private static boolean is_recording = false;

  // The verbose output flag
  private final boolean VERBOSE = false;

  // The recorder task
  private RecorderTask recorderTask = new RecorderTask();

  // The encoder
  private AudioEncoder audioEncoder;

  // The constructor
  public AudioSoftwarePoller() { }

  // The setter for the encoder
  public void setAudioEncoder(AudioEncoder avcEncoder) {
    this.audioEncoder = avcEncoder;
  }

  // Set the number of samples per frame (Default is 1024). Call this before startPolling().
  // The output of emptyBuffer() will be equal to, or a multiple of, this value.
  public void setSamplesPerFrame(int samples_per_frame) {
    if (!is_recording)
      this.recorderTask.samples_per_frame = samples_per_frame;
  }

  // Return the number of microseconds represented by each audio frame
  // calculated with the sampling rate and samples per frame
  public long getMicroSecondsPerFrame(){
    if(US_PER_FRAME == 0){
      US_PER_FRAME = (SAMPLE_RATE / recorderTask.samples_per_frame) * 1000000;
    }
    return US_PER_FRAME;
  }

  // Reuse buffer
  public void recycleInputBuffer(byte[] buffer){
    recorderTask.data_buffer.offer(buffer);
  }

  // Begin polling audio and transferring it to the buffer. Call this before emptyBuffer().
  public void startPolling() {
    new Thread(recorderTask).start();
  }

  // Stop polling audio.
  public void stopPolling() {
    // Will stop recording after next sample received by recorderTask
    is_recording = false;
  }

  // Thread for recording audio samples
  public class RecorderTask implements Runnable {
    // The size of the buffer
    public int buffer_size;

    // The number of samples per frame
    //public int samples_per_frame = 1024;    // codec-specific
    public int samples_per_frame = 2048;    // codec-specific

    // The last buffer index written to
    public int buffer_write_index = 0;

    // The total number of written frames
    public int total_frames_written = 0;

    // The buffer for the audio data
    ArrayBlockingQueue<byte[]> data_buffer = new ArrayBlockingQueue<byte[]>(50);

    // The status of the operation
    int read_result = 0;

    public void run() {
      // Get the minimum buffer size based on the given parameters
      int min_buffer_size = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT);

      // Calculate the actual buffer size
      this.buffer_size = samples_per_frame * FRAMES_PER_BUFFER;

      // Ensure buffer is adequately sized for the AudioRecord
      // object to initialize
      if (buffer_size < min_buffer_size)
        buffer_size = ((min_buffer_size / samples_per_frame) + 1) * samples_per_frame * 2;

      for(int x=0; x < 25; x++)
        data_buffer.add(new byte[samples_per_frame]);

      // Init the audio recorder
      AudioRecord audio_recorder;
      audio_recorder = new AudioRecord(
          MediaRecorder.AudioSource.MIC,       // source
          SAMPLE_RATE,                         // sample rate, hz
          CHANNEL_CONFIG,                      // channels
          AUDIO_FORMAT,                        // audio format
          buffer_size);                        // buffer size (bytes)

      // Start the recording
      audio_recorder.startRecording();
      is_recording = true;
      Log.i(TAG, "SW recording begin");

      long audioPresentationTimeNs;
      while (is_recording) {
        audioPresentationTimeNs = System.nanoTime();
        byte[] this_buffer;

        // Write data to the buffer
        if(data_buffer.isEmpty()){
          this_buffer = new byte[samples_per_frame];
        }else{
          this_buffer = data_buffer.poll();
        }

        // Get the result of the operation
        read_result = audio_recorder.read(this_buffer, 0, samples_per_frame);

        // Log information about the process
        if (VERBOSE)
          Log.i(TAG, String.valueOf(buffer_write_index) + " - " + String.valueOf(buffer_write_index + samples_per_frame - 1));
        if(read_result == AudioRecord.ERROR_BAD_VALUE || read_result == AudioRecord.ERROR_INVALID_OPERATION)
          Log.e(TAG, "Read error");
        total_frames_written++;
        if(audioEncoder != null){
          audioEncoder.offerAudioEncoder(this_buffer, audioPresentationTimeNs);
        }
      }

      // Stop recording
      if (audio_recorder != null) {
        audio_recorder.setRecordPositionUpdateListener(null);
        audio_recorder.release();
        audio_recorder = null;
        Log.i(TAG, "stopped");
      }
    }
  }

}