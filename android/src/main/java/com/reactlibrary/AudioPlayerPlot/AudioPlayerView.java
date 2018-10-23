//
//  AudioPlayerView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import android.content.Context;
import android.graphics.Color;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.widget.RelativeLayout;

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

  // Method to listen for update requests
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onWaveformEvent(WaveformEvent event) {
    if (event.code == 1) {
      this.updateWaveformWithData(event.fileUrl);
    }

    if (event.code == 2) {
      if (event.backgroundColor != null) {
        this.plot.backgroundColor = Color.parseColor(event.backgroundColor);
      }

      if (event.lineColor != null) {
        this.plot.lineColor = Color.parseColor(event.lineColor);
      }

      this.plot.pixelsPerSecond = event.pixelsPerSecond;
    }
  }

  // The constructor
  public AudioPlayerView(Context context) {
    super(context);
    this.context = context;
    EventBus.getDefault().register(this);
    this.init();
  }

  // Reads the bytes of a file
  public static byte[] fileToBytes(File file) {
    // Get the file size in bytes
    int size = (int) file.length();

    // Create the array where the bytes are stored in
    byte[] bytes = new byte[size];

    try {
      // Read the bytes and store it in the array
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

  // Initialize the waveform
  public void init() {
    // Apply layout from xml
    inflate(context, R.layout.audio_player_view, this);

    // Create the plot with the layout defined in the xml
    this.plot = findViewById(R.id.audio_player_waveform);

    // Set the plot line color
    this.plot.setColor();

    // Define the number of bars used for the waveform (1 - 256)
    // More than 256 means that the the bars are overlapping and the waveform get its
    // characteristic style
    this.plot.setDensity(1024f);

    // Set the plot data with the data from the file
    this.plot.setData(null);
  }

  // Add the data to the plot (waveform)
  public void updateWaveformWithData(String fileUrl)  {
    // Get the root directory
    // File root = android.os.Environment.getExternalStorageDirectory();

    // Get a instance of the file
    File audioFile = new File(fileUrl);

    // Read the file duration from the file meta data
    Uri uri = Uri.parse(audioFile.getAbsolutePath());
    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
    mmr.setDataSource(null,uri);
    String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
    float durationInMS = Float.parseFloat(durationStr);

    // Set the duration
    this.plot.setFileDuration(durationInMS);

    // Read the data
    byte[] data = fileToBytes(audioFile);

    // Set the plot data with the data from the file
    this.plot.setData(data);
  }
}