//
//  AudioPlayerViewModule.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableNativeMap;

import org.greenrobot.eventbus.EventBus;

// Represents the AudioPlayerViewManager which manages the AudioRecorderView
public class AudioPlayerViewModule extends ReactContextBaseJavaModule {
  // The react app context
  private final ReactApplicationContext reactContext;

  // The promise response
  private WritableNativeMap jsonResponse = new WritableNativeMap();

  // The constructor
  AudioPlayerViewModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  // Defines the name under which the module/manager is accessable from React Native
  @Override
  public String getName() {
    return "AudioPlayerViewManager";
  }

  // Render a waveform from audio file data
  @ReactMethod
  private void renderByFile(String filePath, Promise promise) {
    // Send event for pausing waveform
    EventBus.getDefault().post(new WaveformEvent(1));

    // Create the promise response
    this.jsonResponse = new WritableNativeMap();
    this.jsonResponse.putString("success", String.valueOf(false));
    this.jsonResponse.putString("error", "");
    this.jsonResponse.putString("value", "");

    try {
      promise.resolve(this.jsonResponse);
    } catch (Error e) {
      promise.reject("Error", e);
    }
  }
}