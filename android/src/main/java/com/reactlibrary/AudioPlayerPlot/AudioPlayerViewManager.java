//
//  AudioPlayerViewManager.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class AudioPlayerViewManager extends SimpleViewManager<AudioPlayerView> {
  // The identifier for React native
  private static final String REACT_CLASS = "AudioPlayerView";

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public AudioPlayerView createViewInstance(ThemedReactContext context) {
    return new AudioPlayerView(context);
  }
}