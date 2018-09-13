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
import com.facebook.react.bridge.WritableNativeMap;

import java.io.File;

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class RNNativeAudioRecorderModule extends ReactContextBaseJavaModule {
  private final ReactApplicationContext reactContext;


  private AudioRecording mAudioRecording;

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

    mAudioRecording = new AudioRecording();

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

    AudioRecording.OnAudioRecordListener onRecordListener = new AudioRecording.OnAudioRecordListener() {

      @Override
      public void onRecordFinished() {
        System.out.println("onFinish");
      }

      @Override
      public void onError(int e) {
        System.out.println("onError" + e);
      }

      @Override
      public void onRecordingStarted() {
        System.out.println("onStart");
      }
    };

    File root = android.os.Environment.getExternalStorageDirectory();
    File dir = new File (root.getAbsolutePath() + "/download");

    String fPath = dir + "/" + System.currentTimeMillis() + ".aac";

    mAudioRecording.setOnAudioRecordListener(onRecordListener);
    mAudioRecording.setFile(fPath);

    mAudioRecording.startRecording();

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
    if( mAudioRecording != null){
      mAudioRecording.stopRecording(false);
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
}