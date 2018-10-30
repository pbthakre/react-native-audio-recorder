//
//  StaticWaveformView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.View;
import com.reactlibrary.R;

// Represents the waveform of a file
public class StaticWaveformView extends View {
  // The wrapper for the style information
  private Paint waveform;

  // The line in the middle (vertical) of the waveform
  private Paint baseLine;

  // The file data
  private byte[] bytes;

  // The density of the waveform
  private float density = 257;

  // The background color of the waveform
  private int backgroundColor = Color.TRANSPARENT;

  // The line color of the waveform
  private int lineColor = getResources().getColor(R.color.brandColor);

  // The pixels per second
  private Double pixelsPerSecond = 6.0;

  // The duration of the audio file to be visualized
  private float fileDuration = 0.0f;

  // Constructor
  public StaticWaveformView(Context context) {
    super(context);
    init();
  }

  // Constructor 2
  public StaticWaveformView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init();
  }

  // Constructor 3
  public StaticWaveformView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init();
  }

  // Initialize the baseline
  private void init() {
    // Init the waveform
    this.waveform = new Paint();

    // Init the baseline
    this.baseLine = new Paint();
    this.baseLine.setColor(this.lineColor);
    this.baseLine.setStrokeWidth(5);
  }

  // Setter for file duration
  public void setFileDuration(float duration) {
    this.fileDuration = duration;
  }

  // Setter for density
  public void setDensity(float density) {
    this.density = density;
  }

  // Setter for background color
  public void setBackgroundColor(int backgroundColor) {
    this.backgroundColor = backgroundColor;
  }

  // Setter for line color
  public void setLineColor(int lineColor) {
    this.lineColor = lineColor;
  }

  // Setter for line color
  public void setPixelsPerSecond(double pixelsPerSecond) {
    this.pixelsPerSecond = pixelsPerSecond;
  }

  // Draw the file data as waveform
  @Override
  protected void onDraw(Canvas canvas) {
    // Get screen width
    DisplayMetrics metrics = getResources().getDisplayMetrics();
    int widthPixels = metrics.widthPixels;

    // Calculate the plot width based on the number of pixels per second and the file duration
    float calculatedPlotWidth = this.pixelsPerSecond.floatValue() * (this.fileDuration / 1000);

    // Check if data is available
    if (this.bytes != null) {
      // Create a straight line before the file waveform so that it starts in the middle of the screen
      canvas.drawLine(0, getHeight() / 2f, widthPixels / 2f, (getHeight() / 2f), this.baseLine);

      // Calculate the bar width based on the total plot width
      float barWidth = (calculatedPlotWidth / this.density) * metrics.density;
      float div = this.bytes.length / this.density;

      // Set baseline settings
      this.baseLine.setColor(getResources().getColor(R.color.brandColor));
      this.baseLine.setStrokeWidth(5);

      // Set plot settings
      this.waveform.setColor(getResources().getColor(R.color.brandColor));
      this.waveform.setStrokeWidth(5);

      // Calculate the bar position based on the given parameters
      for (int i = 0; i < this.density; i++) {
        int bytePosition = (int) Math.ceil(i * div);
        int top = canvas.getHeight() / 2
                + (128 - Math.abs(this.bytes[bytePosition]))
                * (canvas.getHeight() / 2) / 128;

        int bottom = canvas.getHeight() / 2
                - (128 - Math.abs(this.bytes[bytePosition]))
                * (canvas.getHeight() / 2) / 128;

        float barX = (i * barWidth) + (barWidth / 2);

        // Draw the waveform (mirrored)
        canvas.drawLine(barX + widthPixels / 2f, bottom, barX + widthPixels / 2f, canvas.getHeight() / 2f, this.waveform);
        canvas.drawLine(barX + widthPixels / 2f , top, barX + widthPixels / 2f, canvas.getHeight() / 2f, this.waveform);
      }

      canvas.drawLine((widthPixels / 2f), (getHeight() / 2f), (widthPixels / 2f) + calculatedPlotWidth, (getHeight() / 2f), this.waveform);

      // Draw the second part of the baseline after the waveform
      canvas.drawLine((widthPixels / 2f) + (calculatedPlotWidth * metrics.density), (getHeight() / 2f), (widthPixels / 2f) + (calculatedPlotWidth * metrics.density) + (widthPixels / 2f), (getHeight() / 2f), this.baseLine);

      super.onDraw(canvas);
    }
  }

  // Setter for file data
  public void setData(byte[] bytes) {
    // Set the audio file data and redraw waveform
    this.bytes = bytes;
    this.invalidate();
  }
}