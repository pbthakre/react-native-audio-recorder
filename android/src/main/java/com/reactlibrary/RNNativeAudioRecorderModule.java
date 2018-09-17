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
  // The react app context
  private final ReactApplicationContext reactContext;

  // The audio recording engine wrapper
  private AudioRecording audioRecording;

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

    // Instantiate the audio recording engine
    audioRecording = new AudioRecording();

    // Create the promise response
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

    // Instantiate an event listener on the audio recording engine
    AudioRecording.OnAudioRecordListener onRecordListener = new AudioRecording.OnAudioRecordListener() {
      // Recording started
      @Override
      public void onRecordingStarted() {
        System.out.println("onStart");
      }

      // Recording finished
      @Override
      public void onRecordFinished() {
        System.out.println("onFinish");
      }

      // Recording failed
      @Override
      public void onError(int e) {
        System.out.println("onError" + e);
      }
    };

    // Get the root directory
    File root = android.os.Environment.getExternalStorageDirectory();

    // Create a new file instance at the destination folder
    File dir = new File (root.getAbsolutePath() + "/records");

    // Create a destination path of the folder the current timestamp and the file extension
    String fPath = dir + "/" + System.currentTimeMillis() + ".aac";

    // Set the listener on the audio recording engine
    audioRecording.setOnAudioRecordListener(onRecordListener);

    // Set the destination file path on the audio recording engine
    audioRecording.setFile(fPath);

    // Start the recording
    audioRecording.startRecording();

    // Create the promise response
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
    if(audioRecording != null){
      audioRecording.stopRecording(false);
    }

    // Create the promise response
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