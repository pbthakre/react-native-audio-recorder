//
//  DynamicWaveformEvent.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

// Represents an event for transmitting waveform state changes
public class DynamicWaveformEvent {
  //1: Resume Waveform
  //2: Pause Waveform
  public int code;
  public boolean isPaused = true;
  // The background color of the waveform
  public final String backgroundColor;

  // The line color of the waveform
  public final String lineColor;

  // Constructor
  public DynamicWaveformEvent(int code, String backgroundColor, String lineColor) {
    this.code = code;
    this.backgroundColor = backgroundColor;
    this.lineColor = lineColor;
  }

  public void setPaused(boolean paused) {
    this.isPaused = paused;
  }
}