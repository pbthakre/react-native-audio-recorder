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

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class RNNativeAudioRecorderModule extends ReactContextBaseJavaModule {
  private final ReactApplicationContext reactContext;

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

  @ReactMethod
  public void setupRecorder(Promise promise) {
    System.out.println("Setup Recorder");

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