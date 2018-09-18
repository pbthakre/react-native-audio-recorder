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