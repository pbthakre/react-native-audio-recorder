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
import android.support.v4.content.ContextCompat;
import android.util.AttributeSet;
import android.view.View;

import com.reactlibrary.R;

/*
 * Copyright (C) 2017 Gautam Chibde
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

/**
 * Custom view that creates a Line and Bar visualizer effect for
 * the android {@link android.media.MediaPlayer}
 * <p>
 * Created by gautam chibde on 22/11/17.
 */

/*public class StaticWaveformView extends BaseVisualizer {
  private Paint middleLine;
  private float density;
  private int gap;

  public StaticWaveformView(Context context) {
    super(context);
  }

  public StaticWaveformView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
  }

  public StaticWaveformView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  @Override
  protected void init() {
    density = 50;
    gap = 4;
    middleLine = new Paint();
    middleLine.setColor(Color.BLUE);
  }

  *//**
   * Sets the density to the Bar visualizer i.e the number of bars
   * to be displayed. Density can vary from 10 to 256.
   * by default the value is set to 50.
   *
   * @param density density of the bar visualizer
   *//*
  public void setDensity(float density) {
    if (this.density > 180) {
      this.middleLine.setStrokeWidth(1);
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

  @Override
  protected void onDraw(Canvas canvas) {
    if (middleLine.getColor() != Color.BLUE) {
      middleLine.setColor(color);
    }
    if (bytes != null) {
      float barWidth = getWidth() / density;
      float div = bytes.length / density;
      canvas.drawLine(0, getHeight() / 2, getWidth(), getHeight() / 2, middleLine);
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
}*/

public class StaticWaveformView extends View {

  /**
   * constant value for Height of the bar
   */
  public static final int VISUALIZER_HEIGHT = 28;

  /**
   * bytes array converted from file.
   */
  private byte[] bytes;

  /**
   * Percentage of audio sample scale
   * Should updated dynamically while audioPlayer is played
   */
  private float denseness;

  /**
   * Canvas painting for sample scale, filling played part of audio sample
   */
  private Paint playedStatePainting = new Paint();
  /**
   * Canvas painting for sample scale, filling not played part of audio sample
   */
  private Paint notPlayedStatePainting = new Paint();

  private int width;
  private int height;

  public StaticWaveformView(Context context) {
    super(context);
    init();
  }

  public StaticWaveformView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init();
  }

  private void init() {
    bytes = null;

    playedStatePainting.setStrokeWidth(1f);
    playedStatePainting.setAntiAlias(true);
    playedStatePainting.setColor(ContextCompat.getColor(getContext(), R.color.gray));
    notPlayedStatePainting.setStrokeWidth(1f);
    notPlayedStatePainting.setAntiAlias(true);
    notPlayedStatePainting.setColor(ContextCompat.getColor(getContext(), R.color.colorAccent));
  }

  /**
   * update and redraw Visualizer view
   */
  public void updateVisualizer(byte[] bytes) {
    this.bytes = bytes;
    invalidate();
  }

  /**
   * Update player percent. 0 - file not played, 1 - full played
   *
   * @param percent
   */
  public void updatePlayerPercent(float percent) {
    denseness = (int) Math.ceil(width * percent);
    if (denseness < 0) {
      denseness = 0;
    } else if (denseness > width) {
      denseness = width;
    }
    invalidate();
  }

  @Override
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    super.onLayout(changed, left, top, right, bottom);
    width = getMeasuredWidth();
    height = getMeasuredHeight();
  }

  @Override
  protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    if (bytes == null || width == 0) {
      return;
    }
    float totalBarsCount = width / dp(3);
    if (totalBarsCount <= 0.1f) {
      return;
    }
    byte value;
    int samplesCount = (bytes.length * 8 / 5);
    float samplesPerBar = samplesCount / totalBarsCount;
    float barCounter = 0;
    int nextBarNum = 0;

    int y = (height - dp(VISUALIZER_HEIGHT)) / 2;
    int barNum = 0;
    int lastBarNum;
    int drawBarCount;

    for (int a = 0; a < samplesCount; a++) {
      if (a != nextBarNum) {
        continue;
      }
      drawBarCount = 0;
      lastBarNum = nextBarNum;
      while (lastBarNum == nextBarNum) {
        barCounter += samplesPerBar;
        nextBarNum = (int) barCounter;
        drawBarCount++;
      }

      int bitPointer = a * 5;
      int byteNum = bitPointer / Byte.SIZE;
      int byteBitOffset = bitPointer - byteNum * Byte.SIZE;
      int currentByteCount = Byte.SIZE - byteBitOffset;
      int nextByteRest = 5 - currentByteCount;
      value = (byte) ((bytes[byteNum] >> byteBitOffset) & ((2 << (Math.min(5, currentByteCount) - 1)) - 1));
      if (nextByteRest > 0) {
        value <<= nextByteRest;
        value |= bytes[byteNum + 1] & ((2 << (nextByteRest - 1)) - 1);
      }

      for (int b = 0; b < drawBarCount; b++) {
        int x = barNum * dp(3);
        float left = x;
        float top = y + dp(VISUALIZER_HEIGHT - Math.max(1, VISUALIZER_HEIGHT * value / 31.0f));
        float right = x + dp(2);
        float bottom = y + dp(VISUALIZER_HEIGHT);
        if (x < denseness && x + dp(2) < denseness) {
          canvas.drawRect(left, top, right, bottom, notPlayedStatePainting);
        } else {
          canvas.drawRect(left, top, right, bottom, playedStatePainting);
          if (x < denseness) {
            canvas.drawRect(left, top, right, bottom, notPlayedStatePainting);
          }
        }
        barNum++;
      }
    }
  }

  public int dp(float value) {
    if (value == 0) {
      return 0;
    }
    return (int) Math.ceil(getContext().getResources().getDisplayMetrics().density * value);
  }
}
