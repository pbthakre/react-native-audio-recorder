//
//  WaveformEvent.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

// Represents an event for transmitting waveform state changes
public class WaveformEvent {
  //1: Resume Waveform
  //2: Pause Waveform
  public final int code;

  // Constructor
  WaveformEvent(int code) {
    this.code = code;
  }
}