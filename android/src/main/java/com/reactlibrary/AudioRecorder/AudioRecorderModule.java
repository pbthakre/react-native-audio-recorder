//
//  AudioRecorderModule.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 10.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.util.Log;
import com.facebook.react.bridge.*;
import org.greenrobot.eventbus.EventBus;
import wseemann.media.FFmpegMediaMetadataRetriever;

import java.io.File;

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class AudioRecorderModule extends ReactContextBaseJavaModule {
  // The class identifier
  public static final String TAG = "AudioRecorderModule";

  // The audio recording engine wrapper
  private AudioRecording audioRecording;

  // The promise response
  private WritableNativeMap jsonResponse = null;

  // The constructor
  AudioRecorderModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  // Defines the name under which the module/manager is accessible from React Native
  @Override
  public String getName() {
    // !!! This is not a wrong, don't change this,
    // this is necessary as in Android RN the module is the manager
    return "AudioRecorderViewManager";
  }

  // Pass properties from React Native to the waveform
  @ReactMethod
  public void passProperties(String backgroundColor, String lineColor) {
    // Send event for updating waveform with new parameters
    EventBus.getDefault().post(new DynamicWaveformEvent(3, backgroundColor, lineColor));
  }

  // Instantiates all the things needed for recording
  @ReactMethod
  public void setupRecorder(Promise promise) {
    Log.i(TAG, "Setup Recorder");

    // Send event for pausing the waveform
    EventBus.getDefault().post(new DynamicWaveformEvent(2, null, null));

    try {
      // Instantiate the audio recording engine
      this.audioRecording = new AudioRecording();

      // Create the promise response
      this.jsonResponse = new WritableNativeMap();
      this.jsonResponse.putBoolean("success", true);
      this.jsonResponse.putString("error", "");
      this.jsonResponse.putString("value", "");

      promise.resolve(this.jsonResponse);
    } catch (Exception e) {
      promise.reject("Error", e.getLocalizedMessage(), e);
    }
  }

  // Starts the recording of audio
  @ReactMethod
  private void startRecording(String fileName, Double startTimeInMs, Promise promise) {
    Log.i(TAG, "Start Recording");

    try {
      this.audioRecording.startRecording(fileName, startTimeInMs);

      // Send event for resuming waveform
      EventBus.getDefault().post(new DynamicWaveformEvent(1, null, null));

      // Create the promise response
      this.jsonResponse = new WritableNativeMap();
      this.jsonResponse.putBoolean("success", true);
      this.jsonResponse.putString("error", "");
      this.jsonResponse.putString("value", "");

      promise.resolve(jsonResponse);
    } catch (Exception e) {
      promise.reject("Error", e.getLocalizedMessage(), e);
    }
  }

  // Stops audio recording and stores the recorded data in a file
  @ReactMethod
  private void stopRecording(final Promise promise) {
    try {
      File recordedFile = null;

      if(this.audioRecording != null){
        // Send event for pausing waveform
        EventBus.getDefault().post(new DynamicWaveformEvent(2, null, null));

        // Get the file location back from the audio recorder
        recordedFile = this.audioRecording.stopRecording();
      }

      // Get the file duration and resolve the promise
      final File rf = recordedFile;
      new android.os.Handler().postDelayed(
          new Runnable() {
            public void run() {
              FFmpegMediaMetadataRetriever mmr = new FFmpegMediaMetadataRetriever();
              mmr.setDataSource(rf.getAbsolutePath());
              String durationStr = mmr.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_DURATION);
              mmr.release();

              // Create the promise response
              jsonResponse = new WritableNativeMap();
              jsonResponse.putBoolean("success", true);
              jsonResponse.putString("error", "");

              WritableNativeMap metaDataArray = new WritableNativeMap();
              metaDataArray.putString("fileName", rf.getAbsolutePath());
              metaDataArray.putString("fileDurationInMs", String.valueOf(durationStr));

              jsonResponse.putMap("value", metaDataArray);

              promise.resolve(jsonResponse);
            }
          },
          500);
    } catch (Exception e) {
      promise.reject("Error", e.getLocalizedMessage(), e);
    }
  }
}