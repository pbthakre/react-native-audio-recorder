package com.reactlibrary.AudioRecorder;

import android.content.Context;
import android.widget.RelativeLayout;

import com.am.siriview.DrawView;
import com.reactlibrary.R;

public class AudioRecorderView extends RelativeLayout {
  private Context context;

  public AudioRecorderView(Context context) {
    super(context);
    this.context = context;
    this.init();
  }

  public void init() {
    // Apply layout from xml
    inflate(context, R.layout.audio_recorder_view, this);

    // RelativeLayout ll = (RelativeLayout) findViewById(R.id.audio_recorder_waveform);
    DrawView waveform = findViewById(R.id.audio_recorder_waveform);
    waveform.amplitude = 0;
    waveform.frequency = 0;
    waveform.numberOfWaves = 1;
    waveform.phaseShift = 0.5f;
  }
}