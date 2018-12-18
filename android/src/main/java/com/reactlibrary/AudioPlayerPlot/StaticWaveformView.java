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
  private short[] shorts;

  // The density of the waveform
  private float density = 357f;

  // The background color of the waveform
  private int backgroundColor = Color.TRANSPARENT;

  // The line color of the waveform
  private int lineColor = getResources().getColor(R.color.brandColor);

  // The pixels per second
  private Double pixelsPerSecond = 6.0;

  // The duration of the audio file to be visualized
  private float fileDuration = 0.0f;

  private short maxAmplitude = 0;

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

      //canvas.drawPaint(this.baseLine);
    // Get screen width
    DisplayMetrics metrics = getResources().getDisplayMetrics();
    int widthPixels = metrics.widthPixels;

   // Check if data is available
    if (this.shorts != null) {
        // Calculate the plot width based on the number of pixels per second and the file duration
        float calculatedPlotWidth = this.shorts.length;

        // Create a straight line before the file waveform so that it starts in the middle of the screen
     // canvas.drawLine(0, getHeight() / 2f, widthPixels / 2f, (getHeight() / 2f), this.baseLine);

      // Calculate the bar width based on the total plot width
      float barWidth = 1.0f;

      // Set baseline settings
      this.baseLine.setColor(getResources().getColor(R.color.brandColor));
      this.baseLine.setStrokeWidth(5);

      // Set plot settings
      this.waveform.setColor(getResources().getColor(R.color.brandColor));
      this.waveform.setStrokeWidth(5);
        float canvasHeightOneSide = canvas.getHeight()/2f;
      // Calculate the bar position based on the given parameters

        for (int i = 0; i < this.shorts.length; i++) {

            float value = (float)(canvasHeightOneSide * (0.65f) * ((float) this.shorts[i]) * (1.0/maxAmplitude));
            float top = canvasHeightOneSide + value;
            float bottom = canvasHeightOneSide - value;

            float barX = (i * barWidth);

          // Draw the waveform (mirrored)
          canvas.drawLine(barX + 0.0f , top + 0.0f, barX + barWidth, canvasHeightOneSide + 0.0f, this.waveform);
          canvas.drawLine(barX + 0.0f, canvasHeightOneSide + 0.0f, barX + barWidth, bottom + 0.0f, this.waveform);
        }

      //canvas.drawLine((widthPixels / 2f), (getHeight() / 2f), (widthPixels / 2f) + calculatedPlotWidth, (getHeight() / 2f), this.waveform);

      // Draw the second part of the baseline after the waveform
     // canvas.drawLine((widthPixels / 2f) + (calculatedPlotWidth * metrics.density), (getHeight() / 2f), (widthPixels / 2f) + (calculatedPlotWidth * metrics.density) + (widthPixels / 2f), (getHeight() / 2f), this.baseLine);

      super.onDraw(canvas);
    }
  }

  // Setter for file data
  public void setData(short[] bytes) {
    // Set the audio file data and redraw waveform
    this.shorts = bytes;
    this.invalidate();
  }

    public void setMaxAmplitude(short maxAmplitude) {
        this.maxAmplitude = maxAmplitude;
    }
}