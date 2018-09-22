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
import android.graphics.Paint;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.reactlibrary.R;

import android.graphics.Color;

// Represents the waveform of a file
public class StaticWaveformView extends BaseStaticWaveform {
  // The line in the middle (vertical) of the waveform
  private Paint baseLine;

  // The density of thw waveform
  private float density = 128;

  // The gap size between the bars
  private int gap = 4;

  // Constructor
  public StaticWaveformView(Context context) {
    super(context);
  }

  // Constructor 2
  public StaticWaveformView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
  }

  // Constructor 3
  public StaticWaveformView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  // Initialize the baseline
  @Override
  protected void init() {
    // Init baseline
    this.baseLine = new Paint();
    this.baseLine.setColor(getResources().getColor(R.color.brandColor));
  }

  // Setter for density
  public void setDensity(float density) {
    if (this.density > 180) {
      this.baseLine.setStrokeWidth(1);
      this.gap = 1;
    } else {
      this.gap = 4;
    }
    this.density = density;
    if (density > 256) {
      this.density = 250;
      this.gap = 0;
    } else if (density <= 10) {
      this.density = 10;
    }
  }

  // Draw the file data as waveform
  @Override
  protected void onDraw(Canvas canvas) {
    if (baseLine.getColor() != Color.BLUE) {
      baseLine.setColor(Color.RED);
    }
    if (bytes != null) {
      float barWidth = getWidth() / density;
      float div = bytes.length / density;
      canvas.drawLine(0, getHeight() / 2, getWidth(), getHeight() / 2, baseLine);
      paint.setStrokeWidth(barWidth - gap);

      for (int i = 0; i < density; i++) {
        int bytePosition = (int) Math.ceil(i * div);
        int top = canvas.getHeight() / 2
                + (128 - Math.abs(bytes[bytePosition]))
                * (canvas.getHeight() / 2) / 128;

        int bottom = canvas.getHeight() / 2
                - (128 - Math.abs(bytes[bytePosition]))
                * (canvas.getHeight() / 2) / 128;

        float barX = (i * barWidth) + (barWidth / 2);
        canvas.drawLine(barX, bottom, barX, canvas.getHeight() / 2, paint);
        canvas.drawLine(barX, top, barX, canvas.getHeight() / 2, paint);
      }
      super.onDraw(canvas);
    }
  }
}
