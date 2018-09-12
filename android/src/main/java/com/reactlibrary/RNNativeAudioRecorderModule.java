//
//  RNNativeAudioRecorderModule.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 10.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.File;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import android.os.Environment;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class RNNativeAudioRecorderModule extends ReactContextBaseJavaModule {
  private final ReactApplicationContext reactContext;

  private static final int RECORDER_SAMPLERATE = 44100;

  private static final int RECORDER_CHANNELS = AudioFormat.CHANNEL_IN_STEREO;

  private static final int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_8BIT;

  private AudioRecord recorder = null;
  private Thread recordingThread = null;
  private boolean isRecording = false;

  private int bufferSize = AudioRecord.getMinBufferSize(RECORDER_SAMPLERATE,
          RECORDER_CHANNELS, RECORDER_AUDIO_ENCODING);

  private int BufferElements2Rec = 1024; // want to play 2048 (2K) since 2 bytes we use only 1024
  private int BytesPerElement = 2; // 2 bytes in 16bit format

  private byte[] audioData = new byte[bufferSize];

  // The promise response
  private WritableNativeMap jsonResponse = new WritableNativeMap();

  // The constructor
  public RNNativeAudioRecorderModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  // Defines the name under which the module/manager is accessable from React Native
  @Override
  public String getName() {
    return "AudioRecorderViewManager";
  }

  // Instantiates all the things needed for recording
  @ReactMethod
  public void setupRecorder(Promise promise) {
    System.out.println("Setup Recorder");

    jsonResponse = new WritableNativeMap();
    jsonResponse.putString("success", String.valueOf(false));
    jsonResponse.putString("error", "");
    jsonResponse.putString("value", "");

    try {
      promise.resolve(jsonResponse);
    } catch (Error e) {
      promise.reject("Error", e);
    }
  }

  // Starts the recording of audio
  @ReactMethod
  private void startRecording(Double startTimeInMs, String filePath, Promise promise) {
    System.out.println("Start Recording");

    recorder = new AudioRecord(MediaRecorder.AudioSource.MIC,
            RECORDER_SAMPLERATE, RECORDER_CHANNELS,
            RECORDER_AUDIO_ENCODING, bufferSize);

    isRecording = true;


    FileOutputStream outputStream = null;
    ByteArrayOutputStream recordingData = new ByteArrayOutputStream();
    DataOutputStream dataStream = new DataOutputStream(recordingData);

    File sdDir = Environment.getExternalStorageDirectory();

    System.out.println(sdDir);

    File root = android.os.Environment.getExternalStorageDirectory();
    File dir = new File (root.getAbsolutePath() + "/download");

    System.out.println(dir);

    try
    {
      File yourFile = new File(dir, "8k16bitMono.pcm");
      yourFile.createNewFile(); // if file already exists will do nothing
      outputStream = new FileOutputStream(yourFile, false);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }

    while (isRecording)
    {
      recorder.read(audioData, 0, audioData.length);

      try
      {
        outputStream.write(audioData, 0, bufferSize);
      }
      catch (IOException e)
      {
        e.printStackTrace();
      }
    }

    try
    {
      dataStream.flush();
      dataStream.close();
      if (outputStream != null)
        outputStream.close();
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }

    jsonResponse = new WritableNativeMap();
    jsonResponse.putString("success", String.valueOf(false));
    jsonResponse.putString("error", "");
    jsonResponse.putString("value", "");

    try {
      promise.resolve(jsonResponse);
    } catch (Error e) {
      promise.reject("Error", e);
    }
  }

  // Stops audio recording and stores the recorded data in a file
  @ReactMethod
  private void stopRecording(Promise promise) {
    if (null != recorder) {
      isRecording = false;

      recorder.stop();
      recorder.release();

      recorder = null;
      recordingThread = null;

      jsonResponse = new WritableNativeMap();
      jsonResponse.putString("success", String.valueOf(false));
      jsonResponse.putString("error", "");
      jsonResponse.putString("value", "");

      try {
        promise.resolve(jsonResponse);
      } catch (Error e) {
        promise.reject("Error", e);
      }
    }
  }
}