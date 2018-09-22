//
//  AudioPlayerView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import android.content.Context;
import android.media.MediaPlayer;
import android.widget.RelativeLayout;

import com.reactlibrary.AudioRecorder.AmplitudeUpdateEvent;
import com.reactlibrary.R;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class AudioPlayerView extends RelativeLayout {
  private Context context;

  // The plot which represents the waveform
  private StaticWaveformView plot;

  // private MediaPlayer mediaPlayer;

  // Method to listen for amplitude changes received from AudioRecordThread
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onWaveformEvent(AmplitudeUpdateEvent event) {
    // this.trackedAmplitude = event.amplitude;
  }

  // The constructor
  public AudioPlayerView(Context context) {
    super(context);
    this.context = context;
    EventBus.getDefault().register(this);
    this.init();
  }

  public static byte[] fileToBytes(File file) {
    int size = (int) file.length();
    byte[] bytes = new byte[size];
    try {
      BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
      buf.read(bytes, 0, bytes.length);
      buf.close();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return bytes;
  }

  public void updateVisualizer(byte[] bytes) {
    this.plot.updateVisualizer(bytes);
  }

  // Initialize the waveform
  public void init() {
    // Apply layout from xml
    inflate(context, R.layout.audio_player_view, this);



    this.plot = findViewById(R.id.audio_player_waveform);

    // Get the root directory
    File root = android.os.Environment.getExternalStorageDirectory();

    // Create a new file instance at the destination folder
    // File dir = new File (root.getAbsolutePath() + "/download");

    File dir = new File(root.getAbsolutePath() + "/download/" + "1537429704977.m4a");

    byte[] data = fileToBytes(dir);

    this.updateVisualizer(data);

    /* this.plot.setColor(R.color.brandColor);

    this.plot.setDensity(70);

    MediaPlayer.create(context, '/sdcard/Download/1537429704977.m4a');

    this.plot.setPlayer(mediaPlayer.getAudioSessionId());*/
  }
}