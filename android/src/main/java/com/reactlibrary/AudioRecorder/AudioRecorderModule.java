//
//  AudioRecorderModule.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 10.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.util.Log;
import com.facebook.react.bridge.*;

import org.greenrobot.eventbus.EventBus;

import java.io.File;

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class AudioRecorderModule extends ReactContextBaseJavaModule {
  // The class identifier
  public static final String TAG = "AudioRecorderModule";

  // The react app context
  private final ReactApplicationContext reactContext;

  // The audio recording engine wrapper
  private AudioRecording audioRecording;

  // The promise response
  private WritableNativeMap jsonResponse = null;

  // The constructor
  AudioRecorderModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  // Defines the name under which the module/manager is accessable from React Native
  @Override
  public String getName() {
    return "AudioRecorderViewManager";
  }

  // Instantiates all the things needed for recording
  @ReactMethod
  public void setupRecorder(Promise promise) {
    Log.i(TAG, "Setup Recorder");

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
  private void startRecording(Double startTimeInMs, String filePath, Promise promise) {
    Log.i(TAG, "Start Recording");

    try {
      this.audioRecording.startRecording(startTimeInMs, filePath);

      // Send event for resuming waveform
      EventBus.getDefault().post(new WaveformEvent(1));

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
  private void stopRecording(Promise promise) {
    try {
      File recordedFile = null;

      if(this.audioRecording != null){
        // Send event for pausing waveform
        EventBus.getDefault().post(new WaveformEvent(2));

        // Get the file location back from the audio recorder
        recordedFile = this.audioRecording.stopRecording();
      }

      // Read the file duration from the file meta data
      Uri uri = Uri.parse(recordedFile.getAbsolutePath());
      MediaMetadataRetriever mmr = new MediaMetadataRetriever();
      mmr.setDataSource(null,uri);
      String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);

      // Retry while duration is 0 meaning file was not ready for reading
      while(Float.parseFloat(durationStr) == 0) {
        uri = Uri.parse(recordedFile.getAbsolutePath());
        mmr = new MediaMetadataRetriever();
        mmr.setDataSource(null,uri);
        durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
      }

      // Create the promise response
      this.jsonResponse = new WritableNativeMap();
      this.jsonResponse.putBoolean("success", true);
      this.jsonResponse.putString("error", "");

      WritableNativeMap metaDataArray = new WritableNativeMap();
      metaDataArray.putString("fileUrl", recordedFile.getAbsolutePath());
      metaDataArray.putString("fileDurationInMs", durationStr);

      this.jsonResponse.putMap("value", metaDataArray);

      promise.resolve(this.jsonResponse);
    } catch (Exception e) {
      promise.reject("Error", e.getLocalizedMessage(), e);
    }
  }
}