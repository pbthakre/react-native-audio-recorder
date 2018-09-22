//
//  WaveformEvent.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

// Represents an event for transmitting waveform state changes
public class WaveformEvent {
  //1: Draw waveform of file
  public final int code;

  // Constructor
  WaveformEvent(int code) {
    this.code = code;
  }
}