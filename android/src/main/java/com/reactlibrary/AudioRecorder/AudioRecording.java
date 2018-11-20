//
//  AudioRecording.java
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.09.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

package com.reactlibrary.AudioRecorder;

import android.icu.text.SimpleDateFormat;
import android.util.Log;
import com.coremedia.iso.IsoFile;
import com.coremedia.iso.boxes.Container;
import com.googlecode.mp4parser.authoring.Movie;
import com.googlecode.mp4parser.authoring.Track;
import com.googlecode.mp4parser.authoring.builder.DefaultMp4Builder;
import com.googlecode.mp4parser.authoring.container.mp4.MovieCreator;
import com.googlecode.mp4parser.authoring.tracks.AppendTrack;
import com.googlecode.mp4parser.authoring.tracks.CroppedTrack;
import com.reactlibrary.Helpers.FileUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ExecutionException;

// The audio recording engine wrapper
public class AudioRecording {
  // The class tag for identification
  private static final String TAG = "AudioRecording";

  // The encoder which processes the polled data
  private AudioEncoder audioEncoder;

  // The poller which polls the audio data from the microphone
  private AudioSoftwarePoller audioPoller;

  // The position from which to overwrite the recorded data
  private Double pointToOverwriteRecordingInSeconds = 0.00;

  // Defines if the recording is/should be overwriting existing parts of the file
  private boolean isOverwriting = false;

  // The filepath of the file to overwrite
  private String filePath = "";

  // The constructor
  AudioRecording() { }

  // Initiates the recording by starting a thread
  public void startRecording(String filePath, Double startTimeInMs) throws IOException {
    Log.i(TAG, "Recording started");

    // If file path is empty overwriting flag is set to false, "first" new recording
    // otherwise set overwriting flag to true, prepare overwriting from specific point
    if (!filePath.equals("")) {
      this.isOverwriting = true;
      this.pointToOverwriteRecordingInSeconds = startTimeInMs / 1000;

      // Remove timestamp string which is added automatically by Android
      String filePathCleaned = filePath.substring(0, filePath.indexOf("?"));

      this.filePath = filePathCleaned;
    } else {
      this.isOverwriting = false;
    }

    // Create the encoder
    this.audioEncoder = new AudioEncoder();

    // Create the poller
    this.audioPoller = new AudioSoftwarePoller();

    // Pass the encoder to the poller
    this.audioPoller.setAudioEncoder(this.audioEncoder);

    // Pass the poller to the encoder
    this.audioEncoder.setAudioSoftwarePoller(this.audioPoller);

    // Start polling
    this.audioPoller.startPolling();
  }

  // Stops the recording by stopping the thread
  public File stopRecording() throws ExecutionException, InterruptedException, IOException {
    Log.i(TAG, "Recording stopped");

    File destinationPath = null;

    // Stop the recording
    if(this.audioEncoder != null){
      this.audioPoller.stopPolling();
      destinationPath = this.audioEncoder.stop();
    }

    // If in overwriting mode
    if (isOverwriting) {
      // Get the file which should be overwritten
      String previousTape = filePath;
      Movie originalFile = MovieCreator.build(previousTape);
      Movie originalFileCopy2 = MovieCreator.build(previousTape);

      // Start time of cutting is the beginning of the file
      // End time of cutting is the point from which overwriting should start
      double startTime = 0;
      double endTime = this.pointToOverwriteRecordingInSeconds;

      // Get the track of the original file
      Track track = originalFile.getTracks().get(0);

      // Reset the tracks of the original file
      originalFile.setTracks(new LinkedList<Track>());

      // Get the first and the last sample to be extracted
      long startSample = findNextSyncSample(track, startTime);
      long endSample = findNextSyncSample(track, endTime);

      Movie originalFileCut = null;

      String originalCutTape = "/storage/emulated/0/original-cut.m4a";
      String originalCurrentMergedTape = "/storage/emulated/0/original-current-merged.m4a";

      // Init a track list
      List<Track> audioTracks = new LinkedList<Track>();

      /// -----------------------------------------------------------------------------------------------
      /// 1. Cut out the first part of the original file
      /// the part which should not be overwritten

      // Only add the previous part if we are not overwriting from zero
      if (this.pointToOverwriteRecordingInSeconds > 0) {
        // Extract the desired samples and add them back to the clean original file
        originalFile.addTrack(new CroppedTrack(track, startSample, endSample));

        // Write the extracted samples to a temp file
        Container out1 = new DefaultMp4Builder().build(originalFile);
        FileOutputStream fos1 = new FileOutputStream(String.format("/storage/emulated/0/original-cut.m4a", startTime, endTime));
        FileChannel fc1 = fos1.getChannel();
        out1.writeContainer(fc1);
        fc1.close();
        fos1.close();

        /// -----------------------------------------------------------------------------------------------
        /// 2. Merge the first part and the new recorded part
        /// meaning the part which should not be overwritten and the part which should be used to overwrite

        // Get the first part of the original file
        originalFileCut = MovieCreator.build(originalCutTape);

        // Get all tracks of the original file
        for (Track t : originalFileCut.getTracks()) {
          audioTracks.add(t);
        }
      }

      // Get the current recorded part
      String currentTape = destinationPath.getAbsolutePath();
      Movie currentFile = MovieCreator.build(currentTape);

      // Get all tracks of the current file
      audioTracks.add(currentFile.getTracks().get(0));

      // Merge the extracted tracks into one file
      Movie originalCurrentMergedFile = new Movie();
      if (!audioTracks.isEmpty()) {
        originalCurrentMergedFile.addTrack(new AppendTrack(audioTracks.toArray(new Track[audioTracks.size()])));
      }

      // Save the merged parts (first part original and new one) into a temp file
      Container outs2 = new DefaultMp4Builder().build(originalCurrentMergedFile);
      FileChannel fcs2 = new RandomAccessFile(String.format(originalCurrentMergedTape), "rw").getChannel();
      outs2.writeContainer(fcs2);
      fcs2.close();

      // Get the duration of the original file
      IsoFile isoFile = new IsoFile(previousTape);
      double lengthInSecondsOriginalFile = (double)
          isoFile.getMovieBox().getMovieHeaderBox().getDuration() /
          isoFile.getMovieBox().getMovieHeaderBox().getTimescale();

      // Get the duration of the current recorded file
      IsoFile isoFile2 = new IsoFile(currentTape);
      double lengthInSecondsCurrentFile = (double)
          isoFile2.getMovieBox().getMovieHeaderBox().getDuration() /
          isoFile2.getMovieBox().getMovieHeaderBox().getTimescale();

      // Get the duration of the the merged file
      IsoFile isoFile3 = new IsoFile(originalCurrentMergedTape);
      double lengthInSecondsCurrentMergedFile = (double)
          isoFile3.getMovieBox().getMovieHeaderBox().getDuration() /
          isoFile3.getMovieBox().getMovieHeaderBox().getTimescale();

      // Only add the final part if final part is not completely overwritten by the new part
      if (lengthInSecondsCurrentMergedFile < lengthInSecondsOriginalFile) {
        /// -----------------------------------------------------------------------------------------------
        /// 3. Get the second (remaining) part of the original file and merge it with the two other already merged parts
        ///

        // Get the file with the merged parts
        Movie originalCurrentMergedFileCopy = MovieCreator.build(originalCurrentMergedTape);

        // Start time is the point to overwrite from + the length of the current file
        // End time is the length of the original file
        startTime = lengthInSecondsCurrentMergedFile;
        endTime = lengthInSecondsOriginalFile;

        // Create a list for the tracks
        audioTracks = new LinkedList<Track>();

        // Add all tracks of the merge file
        for (Track t : originalCurrentMergedFileCopy.getTracks()) {
          audioTracks.add(t);
        }

        // Get the start and end sample
        startSample = findNextSyncSample(track, startTime);
        endSample = findNextSyncSample(track, endTime);

        // Get the track of the original file
        track = originalFileCopy2.getTracks().get(0);

        // Get the second part of the original file
        Movie originalCut2 = new Movie();
        originalCut2.addTrack(new CroppedTrack(track, startSample, endSample));

        // Add the second part to the list
        audioTracks.add(originalCut2.getTracks().get(0));

        Movie originalCurrentMergedCut = new Movie();

        if (!audioTracks.isEmpty()) {
          originalCurrentMergedCut.addTrack(new AppendTrack(audioTracks.toArray(new Track[audioTracks.size()])));
        }

        // Create filename from timestamp for the new file
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
        String fileName  = dateFormat.format(new Date()) + "--rec.m4a";
        destinationPath = new File("/storage/emulated/0/" + fileName);

        Container out2 = new DefaultMp4Builder().build(originalCurrentMergedCut);
        FileOutputStream fos2 = new FileOutputStream(String.format(destinationPath.getAbsolutePath()));
        FileChannel fc2 = fos2.getChannel();
        out2.writeContainer(fc2);
        fc2.close();
        fos2.close();
      } else {
        // Create filename from timestamp for the new file
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
        String fileName  = dateFormat.format(new Date()) + "--rec.m4a";
        destinationPath = new File("/storage/emulated/0/" + fileName);

        Container out2 = new DefaultMp4Builder().build(originalCurrentMergedFile);
        FileOutputStream fos2 = new FileOutputStream(String.format(destinationPath.getAbsolutePath(), startTime, endTime));
        FileChannel fc2 = fos2.getChannel();
        out2.writeContainer(fc2);
        fc2.close();
        fos2.close();
      }

        /// -----------------------------------------------------------------------------------------------
        /// 4. Cleanup
        ///

        // Delete temporary files
        FileUtils.deleteFile(previousTape);
        FileUtils.deleteFile(currentTape);
        FileUtils.deleteFile(originalCutTape);
        FileUtils.deleteFile(originalCurrentMergedTape);
      }

    return destinationPath;
  }

  // Finds the next sync sample in an audio file based on the given time in seconds
  private static long findNextSyncSample(Track track, double cutHere) {
    long currentSample = 0;
    double currentTime = 0;
    long[] durations = track.getSampleDurations();
    long[] syncSamples = track.getSyncSamples();
    for (int i = 0; i < durations.length; i++) {
      long delta = durations[i];

      if ((syncSamples == null || syncSamples.length > 0 || Arrays.binarySearch(syncSamples, currentSample + 1) >= 0)
          && currentTime > cutHere) {
        return i;
      }
      currentTime += (double) delta / (double) track.getTrackMetaData().getTimescale();
      currentSample++;
    }
    return currentSample;
  }
}