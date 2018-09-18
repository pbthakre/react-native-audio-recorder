package com.reactlibrary.AudioRecorder;

import android.content.Context;
import android.widget.RelativeLayout;

import com.am.siriview.DrawView;
import com.reactlibrary.R;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Timer;
import java.util.TimerTask;

import static com.facebook.react.bridge.UiThreadUtil.runOnUiThread;

public class AudioRecorderView extends RelativeLayout {
  private Context context;

  // The timer which calls the waveform update method
  private Timer timer;

  // The plot which represents the waveform
  private DrawView plot;

  // The current amplitude measured by the microphone
  private Float trackedAmplitude;

  // Method to listen for amplitude changes received from AudioRecordThread
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onRecordingEvent(AmplitudeUpdateEvent event) {
    this.trackedAmplitude = event.amplitude;
  }

  // Method to listen for wave form events from module
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onWaveformEvent(WaveformEvent event) {
    if (event.code == 1) {
      resumeWaveform();
    } else if (event.code == 2) {
      pauseWaveform();
      clearWaveform();
    }
  }

  // The constructor
  public AudioRecorderView(Context context) {
    super(context);
    this.context = context;
    EventBus.getDefault().register(this);
    this.init();
  }

  // Initialize the waveform
  public void init() {
    // Apply layout from xml
    inflate(context, R.layout.audio_recorder_view, this);

    // TODO: Extend SiriWave so that other parameters can be set

    // Init the waveform
    runOnUiThread(new Runnable() {
      @Override
      public void run() {
        plot = (DrawView) findViewById(R.id.audio_recorder_waveform);
        plot.amplitude = 0;
        plot.frequency = 0;
        plot.numberOfWaves = 1;
        plot.phaseShift = 0.5f;
      }
    });
  }

  // Update the waveform according to amplitude change
  private void refreshWaveformWithAmplitude() {
    // Stop further processing if amplitude is not available
    if (this.trackedAmplitude == null) {
      return;
    }

    // Threshold amplitude so that baseline is quite straight
    Float amplitude = this.trackedAmplitude;
    if (amplitude < 0.25) {
      amplitude = 0.0f;
    }

    // Update waveform by setting new amplitude
    final Float finalAmplitude = amplitude;
    runOnUiThread(new Runnable() {
      @Override
      public void run() {
        plot.setMaxAmplitude(finalAmplitude);
      }
    });
  }

  // Resume plot, but keep access level private
  public void resumeWaveform() {
    // Create the timer
    this.timer = new Timer();

    // Set number of sinus waves
    this.plot.frequency = 4;

    // Start the timer for amplitude update processing on waveform
    this.timer.scheduleAtFixedRate(new TimerTask() {
        @Override
        public void run() {
          refreshWaveformWithAmplitude();
        }
      },
      0,
      1
    );
  }

  // Pause plot, but keep access level private
  public void pauseWaveform() {
    this.timer.cancel();
    this.timer.purge();
  }

  // Clear plot, but keep access level private
  public void clearWaveform() {
    this.plot.amplitude = 10;
    this.plot.frequency = 0;
  }
}