package com.reactlibrary;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaFormat;
import android.media.MediaRecorder;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;

// The thread for audio recording
public class AudioRecordThread implements Runnable {
  // The class tag for identification
  private static final String TAG = AudioRecordThread.class.getSimpleName();

  // The recording settings
  private static final int SAMPLE_RATE = 44100;
  private static final int SAMPLE_RATE_INDEX = 4;
  private static final int CHANNELS = 2;
  private static final int BIT_RATE = 32000;

  // The calculated buffer size
  private final int bufferSize;

  // The codec
  private final MediaCodec mediaCodec;

  // The audio record engine
  private final AudioRecord audioRecord;

  // The output stream
  private final OutputStream outputStream;

  // The event listener
  private AudioRecordThread.OnRecorderFailedListener onRecorderFailedListener;

  // The event listener interface
  interface OnRecorderFailedListener {
    void onRecorderFailed();

    void onRecorderStarted();
  }

  // The constructor
  AudioRecordThread(OutputStream outputStream, AudioRecordThread.OnRecorderFailedListener onRecorderFailedListener) throws IOException {
    // Calculate the buffer size based on the other settings
    this.bufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT);

    // Instantiate the audio record engine based on the calculated buffer size
    this.audioRecord = createAudioRecord(this.bufferSize);

    // Instantiate the media codec based on the calculated buffer size
    this.mediaCodec = createMediaCodec(this.bufferSize);

    // Instantiate the output stream
    this.outputStream = outputStream;

    // Instantiate the event listener
    this.onRecorderFailedListener = onRecorderFailedListener;

    // Start the encoder
    this.mediaCodec.start();

    try {
      // Start the recording
      this.audioRecord.startRecording();
    } catch (Exception e) {
      System.out.println(e);
      this.mediaCodec.release();
      throw new IOException(e);
    }
  }

  // Start the thread
  @Override
  public void run() {
    if (this.onRecorderFailedListener != null) {
      System.out.println("onRecorderStarted");
      this.onRecorderFailedListener.onRecorderStarted();
    }

    // Access the buffer info
    MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();

    // Create an input buffer
    ByteBuffer[] codecInputBuffers = this.mediaCodec.getInputBuffers();

    // Create an output buffer
    ByteBuffer[] codecOutputBuffers = this.mediaCodec.getOutputBuffers();

    try {
      // While thread was not stopped do
      while (!Thread.interrupted()) {
        // Let codec handle incoming data (from microphone)
        boolean success = handleCodecInput(this.audioRecord, this.mediaCodec, codecInputBuffers, Thread.currentThread().isAlive());
        if (success) {
          // Let codec handle outgoing data (to destination file)
          handleCodecOutput(this.mediaCodec, codecOutputBuffers, bufferInfo, this.outputStream);
        }
      }
    } catch (IOException e) {
      System.out.println(e);
    } finally {
      // Stop codec and audio record engine
      this.mediaCodec.stop();
      this.audioRecord.stop();

      // Free memory
      this.mediaCodec.release();
      this.audioRecord.release();

      try {
        // Close the file stream
        this.outputStream.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  // Let codec handle incoming data (from microphone)
  private boolean handleCodecInput(AudioRecord audioRecord,
                                   MediaCodec mediaCodec, ByteBuffer[] codecInputBuffers,
                                   boolean running) throws IOException {

    // Create array for storing incoming audio data
    byte[] audioRecordData = new byte[this.bufferSize];

    // Get the length of the incoming data
    int length = audioRecord.read(audioRecordData, 0, audioRecordData.length);

    // Check length validity
    if (length == AudioRecord.ERROR_BAD_VALUE ||
            length == AudioRecord.ERROR_INVALID_OPERATION ||
            length != this.bufferSize) {

      // If length is not equal to buffer size, meaning data was lost, throw error
      if (length != this.bufferSize) {
        if (this.onRecorderFailedListener != null) {
          System.out.println("length != BufferSize calling onRecordFailed");
          this.onRecorderFailedListener.onRecorderFailed();
        }
        return false;
      }
    }

    // Get information about the buffer state
    int codecInputBufferIndex = mediaCodec.dequeueInputBuffer(10 * 1000);

    // If buffer contains data
    if (codecInputBufferIndex >= 0) {
      // Read the buffer data to another buffer
      ByteBuffer codecBuffer = codecInputBuffers[codecInputBufferIndex];

      // Clear the buffer
      codecBuffer.clear();

      // Add the buffer data to another array
      codecBuffer.put(audioRecordData);

      // End of buffer reached
      mediaCodec.queueInputBuffer(codecInputBufferIndex, 0, length, 0, running ? 0 : MediaCodec.BUFFER_FLAG_END_OF_STREAM);
    }

    return true;
  }

  // Let codec handle outgoing data (to destination file)
  private void handleCodecOutput(MediaCodec mediaCodec,
                                 ByteBuffer[] codecOutputBuffers,
                                 MediaCodec.BufferInfo bufferInfo,
                                 OutputStream outputStream)
          throws IOException {

    // Get information about the buffer state
    int codecOutputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 0);

    // If buffer is ready
    while (codecOutputBufferIndex != MediaCodec.INFO_TRY_AGAIN_LATER) {
      if (codecOutputBufferIndex >= 0) {
        // Read the buffer to another buffer
        ByteBuffer encoderOutputBuffer = codecOutputBuffers[codecOutputBufferIndex];

        // Set position and limit
        encoderOutputBuffer.position(bufferInfo.offset);
        encoderOutputBuffer.limit(bufferInfo.offset + bufferInfo.size);

        // If codec was not configured
        if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != MediaCodec.BUFFER_FLAG_CODEC_CONFIG) {
          // Create the header information
          byte[] header = createAdtsHeader(bufferInfo.size - bufferInfo.offset);

          // Write the header to the file
          outputStream.write(header);

          // Create an array for the audio data
          byte[] data = new byte[encoderOutputBuffer.remaining()];

          // Transfer audio data from the buffer to the array
          encoderOutputBuffer.get(data);

          // Write the data to the file
          outputStream.write(data);
        }

        // Clear the buffer
        encoderOutputBuffer.clear();

        // End
        mediaCodec.releaseOutputBuffer(codecOutputBufferIndex, false);
      } else if (codecOutputBufferIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
        // Just write data without header
        codecOutputBuffers = mediaCodec.getOutputBuffers();
      }

      // Set the index
      codecOutputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 0);
    }
  }

  // Create an Audio Data Transfer Stream file header
  private byte[] createAdtsHeader(int length) {
    int frameLength = length + 7;
    byte[] adtsHeader = new byte[7];

    adtsHeader[0] = (byte) 0xFF; // Sync Word
    adtsHeader[1] = (byte) 0xF1; // MPEG-4, Layer (0), No CRC
    adtsHeader[2] = (byte) ((MediaCodecInfo.CodecProfileLevel.AACObjectLC - 1) << 6);
    adtsHeader[2] |= (((byte) SAMPLE_RATE_INDEX) << 2);
    adtsHeader[2] |= (((byte) CHANNELS) >> 2);
    adtsHeader[3] = (byte) (((CHANNELS & 3) << 6) | ((frameLength >> 11) & 0x03));
    adtsHeader[4] = (byte) ((frameLength >> 3) & 0xFF);
    adtsHeader[5] = (byte) (((frameLength & 0x07) << 5) | 0x1f);
    adtsHeader[6] = (byte) 0xFC;

    return adtsHeader;
  }

  // Creates a audio record instance based on the given parameters
  private AudioRecord createAudioRecord(int bufferSize) {
    // Instantiate audio record
    AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_STEREO,
            AudioFormat.ENCODING_PCM_16BIT, bufferSize * 10);

    // An error occured while instantiating
    if (audioRecord.getState() != AudioRecord.STATE_INITIALIZED) {
      System.out.println("Unable to initialize AudioRecord");
      throw new RuntimeException("Unable to initialize AudioRecord");
    }

    // For higher versions apply noise suppressor
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
      if (android.media.audiofx.NoiseSuppressor.isAvailable()) {
        android.media.audiofx.NoiseSuppressor noiseSuppressor = android.media.audiofx.NoiseSuppressor
                .create(audioRecord.getAudioSessionId());
        if (noiseSuppressor != null) {
          noiseSuppressor.setEnabled(true);
        }
      }
    }

    // For higher versions apply gain control
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
      if (android.media.audiofx.AutomaticGainControl.isAvailable()) {
        android.media.audiofx.AutomaticGainControl automaticGainControl = android.media.audiofx.AutomaticGainControl
                .create(audioRecord.getAudioSessionId());
        if (automaticGainControl != null) {
          automaticGainControl.setEnabled(true);
        }
      }
    }

    return audioRecord;
  }

  // Creates a media codec based on given parameters
  private MediaCodec createMediaCodec(int bufferSize) throws IOException {
    // Create the codec
    MediaCodec mediaCodec = MediaCodec.createEncoderByType("audio/mp4a-latm");

    // Define the parameters (format)
    MediaFormat mediaFormat = new MediaFormat();
    mediaFormat.setString(MediaFormat.KEY_MIME, "audio/mp4a-latm");
    mediaFormat.setInteger(MediaFormat.KEY_SAMPLE_RATE, SAMPLE_RATE);
    mediaFormat.setInteger(MediaFormat.KEY_CHANNEL_COUNT, CHANNELS);
    mediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, bufferSize);
    mediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE);
    mediaFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);

    try {
      // Configure the codec with the defined parameters
      mediaCodec.configure(mediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
    } catch (Exception e) {
      System.out.println(e);

      // Free the memory
      mediaCodec.release();
      throw new IOException(e);
    }

    return mediaCodec;
  }
}