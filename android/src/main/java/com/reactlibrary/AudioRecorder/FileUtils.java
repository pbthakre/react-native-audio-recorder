//
//  FileUtils.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 03.10.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.IOException;

// Helper class for file access
public class FileUtils {
  // The class identifier
  static final String TAG = "FileUtils";

  // The directory for storing the audio files in
  static final String OUTPUT_DIR = "Audvice";

  // Returns a Java File initialized to a directory of given name
  // at the root storage location, with preference to external storage.
  // If the directory did not exist, it will be created at the conclusion of this call.
  // If a file with conflicting name exists, this method returns null;
  public static File getRootStorageDirectory(String directory_name){
    // Init the directory instance
    File result;

    // First, try getting access to the sdcard partition
    Log.d(TAG,"Using sdcard");
    result = new File(Environment.getExternalStorageDirectory(), directory_name);

    // Create the directory if it does not exist
    if(!result.exists())
      result.mkdir();
    else if(result.isFile()){
      return null;
    }
    Log.d("getRootStorageDirectory", result.getAbsolutePath());
    return result;
  }

  // Returns a Java File initialized to a directory of given name within the given location.
  public static File getStorageDirectory(File parent_directory, String new_child_directory_name){

    File result = new File(parent_directory, new_child_directory_name);
    if(!result.exists())
      if(result.mkdir())
        return result;
      else{
        Log.e("getStorageDirectory", "Error creating " + result.getAbsolutePath());
        return null;
      }
    else if(result.isFile()){
      return null;
    }

    Log.d("getStorageDirectory", "directory ready: " + result.getAbsolutePath());
    return result;
  }

  // Returns a TempFile with given root, filename, and extension.
  // The resulting TempFile is safe for use with Android's MediaRecorder
  public static File createTempFile(File root, String filename, String extension){
    File output = null;
    try {
      if(filename != null){
        if(!extension.contains("."))
          extension = "." + extension;
        output = new File(root, filename + extension);
        output.createNewFile();
        //output = File.createTempFile(filename, extension, root);
        Log.i(TAG, "Created temp file: " + output.getAbsolutePath());
      }
      return output;
    } catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  public static File createTempFileInRootAppStorage(String filename){
    File recordingDir = FileUtils.getRootStorageDirectory(OUTPUT_DIR);
    return createTempFile(recordingDir, filename.split("\\.")[0], filename.split("\\.")[1]);
  }

  public static void deleteFile(String filePath) {
    File file = new File(filePath);
    file.delete();
  }
}