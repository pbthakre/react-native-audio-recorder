//
//  AudioRecording.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.util.Log;

import java.io.File;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

// The audio recording engine wrapper
public class AudioRecording {
  // The class tag for identification
  private static final String TAG = "AudioRecording";

  // The encoder which processes the polled data
  private AudioEncoder audioEncoder;

  // The poller which polls the audio data from the microphone
  private AudioSoftwarePoller audioPoller;

  // The constructor
  AudioRecording() {}

  // Initiates the recording by starting a thread
  public void startRecording() throws IOException {
    Log.i(TAG, "Recording started");

    // Create the encoder
    this.audioEncoder = new AudioEncoder();

    // Create the poller
    this.audioPoller = new AudioSoftwarePoller();

    // Pass the encoder to the poller
    this.audioPoller.setAudioEncoder(this.audioEncoder);

    // Pass the poller to the encoder
    this.audioEncoder.setAudioSoftwarePoller(this.audioPoller);

    // Start polling
    this.audioPoller.startPolling();
  }

  // Stops the recording by stopping the thread
  public File stopRecording() throws ExecutionException, InterruptedException {
    Log.i(TAG, "Recording stopped");

    File destinationPath = null;

    // Stop the recording
    if(this.audioEncoder != null){
      this.audioPoller.stopPolling();
      destinationPath = this.audioEncoder.stop();
    }

    return destinationPath;
  }
}