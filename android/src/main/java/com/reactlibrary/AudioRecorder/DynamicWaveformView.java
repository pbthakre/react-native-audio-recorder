//
//  DynamicWaveformView.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 18.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;

import com.reactlibrary.R;

// Represents the real-time waveform for recording
public class DynamicWaveformView extends View {
  // The wrapper for the line information
  private Path path;

  // The wrapper for the style information
  private Paint paint;

  // The frequency of the sinus wave. The higher the value, the more sinus wave peaks you will have.
  private float frequency = 1.5f;

  // The amplitude that is used when the incoming amplitude is near zero.
  // Setting a value greater 0 provides a more vivid visualization.
  private float IdleAmplitude = 0.01f;

  // The total number of waves
  private int waveNumber = 6;

  // The phase shift that will be applied with each level setting
  // Change this to modify the animation speed or direction
  private float phaseShift = 0.15f;

  // The offset
  private float initialPhaseOffset = 0.0f;

  // The height of the waves
  private float waveHeight = 10;

  // The position of the wave, 2 = centered vertically
  private float waveVerticalPosition = 2;

  // The color of the line
  private int waveColor;

  // The accumulation of the phase shifts
  private float phase;

  // The current amplitude.
  private float amplitude = 0.01f;

  // Constructor
  public DynamicWaveformView(Context context) {
    super(context);
    if (!isInEditMode())
      init(context, null);
  }

  // Constructor 2
  public DynamicWaveformView(Context context, AttributeSet attrs) {
    super(context, attrs);
    if (!isInEditMode())
      init(context, attrs);
  }

  // Constructor 3
  public DynamicWaveformView(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    if (!isInEditMode())
      init(context, attrs);
  }

  // Init the waveform with the parameters from the layout file
  public void init(Context context, AttributeSet attrs) {
    TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.DynamicWaveformView);
    frequency = a.getFloat(R.styleable.DynamicWaveformView_waveFrequency, frequency);
    IdleAmplitude = a.getFloat(R.styleable.DynamicWaveformView_waveIdleAmplitude, IdleAmplitude);
    phaseShift = a.getFloat(R.styleable.DynamicWaveformView_wavePhaseShift, phaseShift);
    initialPhaseOffset = a.getFloat(R.styleable.DynamicWaveformView_waveInitialPhaseOffset, initialPhaseOffset);
    waveHeight = a.getDimension(R.styleable.DynamicWaveformView_waveHeight, waveHeight);
    waveColor = a.getColor(R.styleable.DynamicWaveformView_waveColor, waveColor);
    waveVerticalPosition = a.getFloat(R.styleable.DynamicWaveformView_waveVerticalPosition, waveVerticalPosition);
    waveNumber = a.getInteger(R.styleable.DynamicWaveformView_waveAmount, waveNumber);

    // Create a path
    path = new Path();
    paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    paint.setStyle(Paint.Style.STROKE);
    paint.setStrokeWidth(2);
    paint.setColor(waveColor);

    // Keep our attributes array for later usage
    a.recycle();
  }

  // Draws the path and updates view
  @Override
  protected void onDraw(Canvas canvas) {
    canvas.drawPath(path, paint);
    updatePath();
  }

  // Calculates the waveform line
  private void updatePath() {
    // Clear the path
    path.reset();

    // Calculate the phase
    phase += phaseShift;

    // Foreach wave
    for (int i = 0; i < waveNumber; i++) {
      float halfHeight = getHeight() / waveVerticalPosition;
      float width = getWidth();
      float mid = width / 2.0f;

      float maxAmplitude = halfHeight - (halfHeight - waveHeight);

      // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
      float progress = 1.0f - (float) i / waveNumber;
      float normedAmplitude = (1.5f * progress - 0.5f) * amplitude;

      for (int x = 0; x < width; x++) {
        float scaling = (float) (-Math.pow(1 / mid * (x - mid), 2) + 1);

        float y = (float) (scaling * maxAmplitude * normedAmplitude * Math.sin(2 * Math.PI * (x / width) * frequency + phase + initialPhaseOffset) + halfHeight);

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }
  }

  // Setter for amplitude
  public void setAmplitude(float amplitude) {
    this.amplitude = amplitude;
    invalidate();
    updatePath();
  }

  // Setter for frequency
  public void setFrequency(float frequency) {
    this.frequency = frequency;
    invalidate();
  }

  // Setter for line color
  public void setWaveColor(int waveColor) {
    paint.setColor(waveColor);
    invalidate();
  }

  // Setter for line width
  public void setStrokeWidth(float strokeWidth) {
    paint.setStrokeWidth(strokeWidth);
    invalidate();
  }
}