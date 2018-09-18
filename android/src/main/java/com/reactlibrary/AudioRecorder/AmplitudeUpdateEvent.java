package com.reactlibrary.AudioRecorder;

// Represents an event for transmitting amplitude changes
public class AmplitudeUpdateEvent {
  // The amplitude
  public final Float amplitude;

  // Constructor
  AmplitudeUpdateEvent(Float amplitude) {
    this.amplitude = amplitude;
  }
}