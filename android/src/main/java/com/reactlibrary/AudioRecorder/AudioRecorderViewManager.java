//
//  AudioRecorderViewManager.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 18.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class AudioRecorderViewManager extends SimpleViewManager<AudioRecorderView> {
  // The identifier for React native
  private static final String REACT_CLASS = "AudioRecorderView";

  // The view
  private AudioRecorderView audioRecorderView = null;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public AudioRecorderView createViewInstance(ThemedReactContext context) {
    AudioRecorderView newView = new AudioRecorderView(context);
    this.audioRecorderView = newView;
    return newView;
  }
}