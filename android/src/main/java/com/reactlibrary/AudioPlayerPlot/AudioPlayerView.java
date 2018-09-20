//
//  AudioPlayerView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import android.content.Context;
import android.widget.RelativeLayout;

import com.reactlibrary.R;

public class AudioPlayerView extends RelativeLayout {
  private Context context;

  // The constructor
  public AudioPlayerView(Context context) {
    super(context);
    this.context = context;
    this.init();
  }

  // Initialize the waveform
  public void init() {
    // Apply layout from xml
    inflate(context, R.layout.audio_player_view, this);
  }
}