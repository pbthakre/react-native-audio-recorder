package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class RNNativeAudioRecorderModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNNativeAudioRecorderModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "AudioRecorderViewManager";
  }

  @ReactMethod
  public void setupRecorder() {
      System.out.println("hello"+"\n"+"world");
  }
}