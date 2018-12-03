//
//  AudioRecorderView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 18.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.content.Context;
import android.graphics.Color;
import android.os.Handler;
import android.widget.RelativeLayout;
import com.reactlibrary.R;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Timer;
import java.util.TimerTask;

public class AudioRecorderView extends RelativeLayout {
  // The timer which calls the waveform update method
  private Timer timer;
  private boolean isPaused;

  // The task the timer executes
  private TimerTask refreshWaveformTask;

  // The handler of the timer
  final Handler handler = new Handler();

  // The plot which represents the waveform
  private DynamicWaveformView plot;

  // The current amplitude measured by the microphone
  private Float trackedAmplitude;

  // The constructor
  public AudioRecorderView(Context context) {
    super(context);

    // Register the event bus
    EventBus.getDefault().register(this);

    // Apply layout from xml
    inflate(context, R.layout.audio_recorder_view, this);

    // Init the waveform
    this.plot = findViewById(R.id.audio_recorder_waveform);
    this.plot.setStrokeWidth(5);
    this.plot.setAmplitude(0);
    this.plot.setFrequency(0);
    this.plot.setWaveColor();

    // Draw straight line
    resumeWaveform();
  }

  // Method to listen for amplitude changes received from AudioRecordThread
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onAmplitudeUpdateEvent(AmplitudeUpdateEvent event) {
    this.trackedAmplitude = event.amplitude;
  }

  // Method to listen for wave form events from module
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onDynamicWaveformEvent(DynamicWaveformEvent event) {
    // Resume the waveform
    if (event.code == 1) {
      isPaused = event.isPaused;
      resumeWaveform();

    } else if (event.code == 2) { // Pause the waveform
      isPaused = event.isPaused;
      pauseWaveform();
      clearWaveform();
    } else if (event.code == 3) { // Set the properties received from RN
      if (event.backgroundColor != null) {
        this.plot.setBackgroundColor(Color.parseColor(event.backgroundColor));
      }

      if (event.lineColor != null) {
        this.plot.setLineColor(Color.parseColor(event.lineColor));
      }
    }
  }

  // Update the waveform according to amplitude change
  private void refreshWaveformWithAmplitude() {
    // Stop further processing if amplitude is not available
    if (this.trackedAmplitude == null) {
      this.trackedAmplitude = 0.0f;
    }

    // Threshold amplitude so that baseline is quite straight
    Float amplitude = (this.trackedAmplitude);
    if(!isPaused) {
      if (amplitude > 8.00f) {
        amplitude = 8.00f;
      } else if (amplitude < 1.50f) {
        amplitude = 0.10f;
      }
    } else {
      amplitude = 0.0f;
    }

    plot.setAmplitude(amplitude);
  }

  // Resume plot, but keep access level private
  public void resumeWaveform() {
    new Thread(new Runnable() {
      public void run() {
      if (timer != null) {
        pauseWaveform();
      }

      // Set number of sinus waves
      plot.setFrequency(4.00f);

      // Create the timer
      timer = new Timer();

      // Initialize the TimerTask's job
      initializeTimerTask();

      // Start the timer for amplitude update processing on waveform
      timer.scheduleAtFixedRate(
          refreshWaveformTask,
          0,
          10
      );
      }
    }).start();
  }

  // Pause plot, but keep access level private
  public void pauseWaveform() {
    if (this.timer != null) {
      this.timer.cancel();
      this.timer = null;
    }
  }

  // Clear plot, but keep access level private
  public void clearWaveform() {
    this.plot.setAmplitude(0);
    this.plot.setFrequency(0);
  }

  // Initialize the waveform (amplitude) update timer task
  public void initializeTimerTask() {
    refreshWaveformTask = new TimerTask() {
      public void run() {
        handler.post(new Runnable() {
          public void run() {
            refreshWaveformWithAmplitude();
          }
        });
      }
    };
  }
}
