//
//  AmplitudeUpdateEvent.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 18.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

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