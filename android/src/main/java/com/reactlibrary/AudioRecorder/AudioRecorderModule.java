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
import com.facebook.react.bridge.*;

import org.greenrobot.eventbus.EventBus;

import java.io.File;

// Represents the AudioRecorderViewManager which manages the AudioRecorderView
public class AudioRecorderModule extends ReactContextBaseJavaModule {
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
    System.out.println("Setup Recorder");

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
    System.out.println("Start Recording");

    try {
      // Instantiate an event listener on the audio recording engine
      AudioRecording.OnAudioRecordListener onRecordListener = new AudioRecording.OnAudioRecordListener() {
        // Recording started
        @Override
        public void onRecordingStarted() {
          System.out.println("onStart");
        }

        // Recording finished
        @Override
        public void onRecordFinished() {
          System.out.println("onFinish");
        }

        // Recording failed
        @Override
        public void onError(int e) {
          System.out.println("onError" + e);
        }
      };

      // Get the root directory
      File root = android.os.Environment.getExternalStorageDirectory();

      // Create a new file instance at the destination folder
      File dir = new File (root.getAbsolutePath() + "/download");

      // Create a destination path of the folder the current timestamp and the file extension
      String fPath = dir + "/" + System.currentTimeMillis() + ".m4a";

      // Set the listener on the audio recording engine
      this.audioRecording.setOnAudioRecordListener(onRecordListener);

      // Set the destination file path on the audio recording engine
      this.audioRecording.setFile(fPath);

      // Start the recording
      this.audioRecording.startRecording();

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
        recordedFile = this.audioRecording.stopRecording(false);
      }

      // Read the file duration from the file meta data
      Uri uri = Uri.parse(recordedFile.getAbsolutePath());
      MediaMetadataRetriever mmr = new MediaMetadataRetriever();
      mmr.setDataSource(null,uri);
      String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);

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