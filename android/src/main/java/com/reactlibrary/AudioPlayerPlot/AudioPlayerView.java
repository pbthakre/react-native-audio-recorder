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
import com.reactlibrary.Helpers.FileUtils;
import com.reactlibrary.R;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.File;

// Represents the player plot waveform wrapper
public class AudioPlayerView extends RelativeLayout {
  // The plot which represents the waveform
  private StaticWaveformView plot;

  // The constructor
  public AudioPlayerView(Context context) {
    super(context);

    // Register the event bus
    EventBus.getDefault().register(this);

    // Apply layout from xml
    inflate(context, R.layout.audio_player_view, this);

    // Create the plot with the layout defined in the xml
    this.plot = findViewById(R.id.audio_player_waveform);

    // Define the number of bars used for the waveform (1 - 256)
    // More than 256 means that the the bars are overlapping and the waveform get its
    // characteristic style
    this.plot.setDensity(257f);

    // Set the plot data with the data from the file
    this.plot.setData(null);
  }

  // Method to listen for waveform update requests
  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onStaticWaveformEvent(StaticWaveformEvent event) {
    // Update the waveform
    if (event.code == 1) {
      this.updateWaveformWithData(event.fileUrl);
    }

    // Set the properties received from RN
    if (event.code == 2) {
      if (event.backgroundColor != null) {
        this.plot.setBackgroundColor(Color.parseColor(event.backgroundColor));
      }

      if (event.lineColor != null) {
        this.plot.setLineColor(Color.parseColor(event.lineColor));
      }

      this.plot.setPixelsPerSecond(event.pixelsPerSecond);
    }
  }

  // Add the data to the plot (waveform)
  private void updateWaveformWithData(String fileUrl)  {
    // Remove timestamp parameter
    String filePathCleaned = fileUrl.substring(0, fileUrl.indexOf("?"));

    // Get an instance of the file
    File audioFile = new File(filePathCleaned);

    // Read the file duration from the file meta data
    Uri uri = Uri.parse(audioFile.getAbsolutePath());
    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
    mmr.setDataSource(null, uri);
    String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
    float durationInMS = Float.parseFloat(durationStr);

    // Set the duration
    this.plot.setFileDuration(durationInMS);

    // Read the file data
    byte[] data = FileUtils.fileToBytes(audioFile);

    // Set the plot data to be the data of the audio file
    this.plot.setData(data);
  }
}