//
//  AudioPlayerViewModule.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

// Represents the AudioPlayerViewManager which manages the AudioRecorderView
public class AudioPlayerViewModule extends ReactContextBaseJavaModule {
  // The react app context
  private final ReactApplicationContext reactContext;

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
}