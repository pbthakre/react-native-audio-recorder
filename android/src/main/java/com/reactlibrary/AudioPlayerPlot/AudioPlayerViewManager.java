package com.reactlibrary.AudioPlayerPlot;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class AudioPlayerViewManager extends SimpleViewManager<AudioPlayerView> {
  // The identifier for React native
  private static final String REACT_CLASS = "AudioPlayerView";

  // The view
  private AudioPlayerView audioPlayerView = null;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public AudioPlayerView createViewInstance(ThemedReactContext context) {
    AudioPlayerView newView = new AudioPlayerView(context);
    this.audioPlayerView = newView;
    return newView;
  }
}