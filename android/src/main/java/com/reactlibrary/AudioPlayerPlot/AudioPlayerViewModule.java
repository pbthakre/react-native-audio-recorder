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
  // The promise response
  private WritableNativeMap jsonResponse = new WritableNativeMap();

  // The constructor
  AudioPlayerViewModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  // Defines the name under which the module/manager is accessible from React Native
  @Override
  public String getName() {
    return "AudioPlayerViewManager";
  }

  // Pass properties from React Native to the waveform
  @ReactMethod
  public void passProperties(String backgroundColor, String lineColor, Double pixelsPerSecond) {
    // Send event for updating waveform with new parameters
    EventBus.getDefault().post(new WaveformEvent(2, "", backgroundColor, lineColor, pixelsPerSecond));
  }

  // Render a waveform from audio file data
  @ReactMethod
  private void renderByFile(String filePath, Promise promise) {
    try {
      // Send event for updating waveform with new audio file data
      EventBus.getDefault().post(new WaveformEvent(1, filePath, null, null, null));

      // Create the promise response
      this.jsonResponse = new WritableNativeMap();
      this.jsonResponse.putBoolean("success", true);
      this.jsonResponse.putString("error", "");
      this.jsonResponse.putString("value", "");

      promise.resolve(jsonResponse);
    } catch (Exception e) {
      promise.reject("Error", e.getLocalizedMessage(), e);
    }
  }
}