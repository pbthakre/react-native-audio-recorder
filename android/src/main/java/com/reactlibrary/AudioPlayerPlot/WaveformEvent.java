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

  // The background color of the waveform
  public final String backgroundColor;

  // The line color of the waveform
  public final String lineColor;

  // The number of pixels per second visible on the screen
  public final Double pixelsPerSecond;

  // Constructor
  WaveformEvent(int code, String fileUrl, String backgroundColor, String lineColor, Double pixelsPerSecond) {
    this.code = code;
    this.fileUrl = fileUrl;
    this.backgroundColor = backgroundColor;
    this.lineColor = lineColor;
    this.pixelsPerSecond = pixelsPerSecond;
  }
}