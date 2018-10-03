//
//  WaveformEvent.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 21.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

// Represents an event for transmitting waveform state changes
public class WaveformEvent {
  //1: Draw waveform of file
  public final int code;

  // The file url to load
  public final String fileUrl;

  // Constructor
  WaveformEvent(int code, String fileUrl) {
    this.code = code;
    this.fileUrl = fileUrl;
  }
}