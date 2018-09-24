//
//  BaseStaticWaveform.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 20.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioPlayerPlot;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

import com.reactlibrary.R;

// Represents the base class for the waveform of a file
abstract public class BaseStaticWaveform extends View {
  // The file data
  protected byte[] bytes;

  // The wrapper for the style information
  protected Paint paint;

  // The default line color
  protected int color = getResources().getColor(R.color.brandColor);

  // Constructor
  public BaseStaticWaveform(Context context) {
    super(context);
    init(null);
    init();
  }

  // Constructor 2
  public BaseStaticWaveform(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(attrs);
    init();
  }

  // Constructor 2
  public BaseStaticWaveform(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(attrs);
    init();
  }

  // Init the waveform
  private void init(AttributeSet attributeSet) {
    paint = new Paint();
  }

  // Setter for line color
  public void setColor(int color) {
    this.color = color;
    this.paint.setColor(this.color);
  }

  // Setter for file data
  public void setData(byte[] bytes) {
    this.bytes = bytes;
  }

  // Init
  protected abstract void init();
}