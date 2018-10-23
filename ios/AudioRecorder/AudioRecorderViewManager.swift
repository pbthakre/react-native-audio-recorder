//
//  AudioRecorderViewManager.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

import Foundation
import UIKit

import AudioKit
import AudioKitUI

// Represents the AudioRecorderViewManager which manages our AudioRecorderView Module
@objc(AudioRecorderViewManager)
class AudioRecorderViewManager : RCTViewManager {
  // The device's microphone
  private let mic = AKMicrophone()

   // The mixer which handles the microphone input
  private var micMixer: AKMixer!

  // The mixer which handles the speaker output
  private var mainMixer: AKMixer!

  // The recorder which handles recording of audio samples via mixer
  private var recorder: AKNodeRecorder!

  // The player which handles playing of audio samples via mixer
  private var player: AKPlayer!

  // The file of recorded audio samples
  private var tape: AKAudioFile!

  // The tape which will then contain all the recorded sub tapes of this session
  var finalTape: AKAudioFile? = nil

  // The name of the file where the current recording is stored in
  private var fileName = "recording.mp4"

  // The file url of the file which should be overwritten
  private var fileToOverwrite = "recording.mp4"
    
  // The duration of the file where the current recording is stored in - in milliseconds
  private var fileDuration = 0

  // The booster which lets control the microphone input properties such as volume
  private var micBooster: AKBooster!

  // The filter node
  private var moogLadder: AKMoogLadder!

  // The native ui view
  private var currentView: AudioRecorderView?

  // The tracker which observes the microphone
  private var microphoneTracker = AKMicrophoneTracker()

  // The position from which to overwrite the recorded data
  private var pointToOverwriteRecordingInSeconds: Double = 0.00

  // Defines if the recording is/should be overwriting existing parts of the file
  private var isOverwriting: Bool = false

  // The promise response
  private var jsonArray: JSON = [
    "success": false,
    "error": "",
    "value": ["fileUrl": "", "fileDurationInMs": "0"]
  ]

  // Error for testing error handling
  // Can be removed anytime later
  enum TestError: Error {
    case runtimeError(String)
  }

  // Instantiates the view
  override func view() -> AudioRecorderView {
    let newView = AudioRecorderView()
    self.currentView = newView
    return newView
  }

  // Tells React Native to use Main Thread
  override class func requiresMainQueueSetup() -> Bool {
    return true
  }
    
  // Received properties from React Native and sets them on the view
  @objc public func passProperties(_ backgroundColor:String, propLineColor lineColor:String) {
    if (backgroundColor != "") {
      let transparentColor = UIColor(white: 1, alpha: 0.0)
      self.currentView?.bgColor = ColorHelper.hexStringToUIColor(hex: backgroundColor, fallback: transparentColor)
    }
    
    if (lineColor != "") {
      let brandColor = UIColor(red: 124.0 / 255.0, green: 219.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
      self.currentView?.lineColor = ColorHelper.hexStringToUIColor(hex: lineColor, fallback: brandColor)
    }
    
    DispatchQueue.main.async {
      self.currentView?.layoutSubviews()
    }
  }

  // Sets the dimensions of the AudioRecorderView to the component dimensions received from React Native
  @objc public func setDimensions(_ width:Double, dimHeight height:Double) {
    self.currentView?.componentWidth = width
    self.currentView?.componentHeight = height

    DispatchQueue.main.async {
      self.currentView?.layoutSubviews()
    }
  }

  // Cleans up
  private func cleanupRecorder(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Remove temporary files from temp directory
      AKAudioFile.cleanTempDirectory()
        
      // Stop AudioKit to prevent errors of duplicate initialization
      try AudioKit.stop()

      // Completed without error
      onSuccess(true)
    } catch {
      // Aborted with error
      AKLog("Cleanup failed.")
      self.jsonArray["error"].stringValue = error.localizedDescription + " - Cleanup failed."
      onError(error)
    }
  }

  // Init new recording session
  private func initRecorderSession(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Create a session with recording/recording and bluetooth output only
      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)

      // Session settings
      // Set number of audio frames which can be hold by the buffer
      AKSettings.bufferLength = .veryLong

      // Don't use default speakers to avoid crackling in audio files (bug of AudioKit!?)
      AKSettings.defaultToSpeaker = true

      // Listen to microphone
      AKSettings.audioInputEnabled = true

      // Completed without error
      onSuccess(true)
    } catch {
      // Aborted with error
      AKLog("Init of session failed.")
      self.jsonArray["error"].stringValue = error.localizedDescription + " - Init of session failed."
      onError(error)
    }
  }

  // Setup virtual devices like, for example, mixer
  private func setupVirtualDevices(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Setup mixer (input handler) for microphone, plus wrap mixer into booster (property handler)
      self.micMixer = AKMixer(self.mic)
      self.micBooster = AKBooster(self.micMixer)

      // Microphone monitoring is muted
      self.micBooster.gain = 0

      // Setup recorder with using microphone mixer as input handler
      self.recorder = try AKNodeRecorder(node: micMixer)

      // Setup player using the recorded audio file
      if let file = self.recorder.audioFile {
        self.player = AKPlayer(audioFile: file)
      }

      // Apply filter which enables to manipulate the signal
      self.moogLadder = AKMoogLadder(self.player)
      self.moogLadder.presetDullNoiseMoogLadder()

      // Create a mixer which combines our filtered node and our microphone node
      self.mainMixer = AKMixer(self.moogLadder, self.micBooster)

      // Completed without error
      onSuccess(true)
    } catch {
      // Aborted with error
      AKLog("Setup of virtual devices failed.")
      self.jsonArray["error"].stringValue = error.localizedDescription + " - Setup of virtual devices failed."
      onError(error)
    }
  }

  // Start the AudioKit engine
  private func startEngine(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Set the signal of the main mixer as output signal
      AudioKit.output = self.mainMixer

      // Start tracking
      self.microphoneTracker.start()

      // Start the audio engine
      try AudioKit.start()

      // Completed without error
      onSuccess(true)
    } catch {
      // Aborted with error
      AKLog("Starting of engine failed.")
      self.jsonArray["error"].stringValue = error.localizedDescription + " - Starting of engine failed."
      onError(error)
    }
  }

  // Setup the final tape which will contain all audio data of one session
  private func setupFinalTape(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Setup the audio tape which will contain the compilation of all the audio data of one session
      self.finalTape = try AKAudioFile()

      // Completed without error
      onSuccess(true)
    }
    catch {
      // Aborted with error
      AKLog("Setup of final tape failed.")
      self.jsonArray["error"].stringValue = error.localizedDescription + " - Setup of final tape failed."
      onError(error)
    }
  }

  // Exports the final tape to a file
  private func exportFinalTapeToFile(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    if (!self.isOverwriting) {
      // Create filename from timestamp for the new file
      let now = Date()
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone.current
      formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
      let dateString = formatter.string(from: now)
      self.fileName = dateString + "--rec.mp4"
    } else {
      // Set file name of overwritten file to the given one
      self.fileName = (NSURL(string: self.fileToOverwrite)?.lastPathComponent)!
    }

    // Store the audio data (final tape) permanently on the device's storage
    self.finalTape?.exportAsynchronously(
      name: self.fileName,
      baseDir: .documents,
      exportFormat: .mp4) {
        exportedFile, error in
          print("myExportCallBack has been triggered. It means that export ended")
          if error == nil {
            // If it is valid:
            if exportedFile != nil {
              print("Export succeeded.")
              // Completed without error
              onSuccess(true)
            }
          } else {
            print("Export failed.")

            // Aborted with error
            self.jsonArray["error"].stringValue = (error?.localizedDescription)! + " - Export failed."
            onError(error!)
          }
    }
  }

  // Resets recorder and current tape
  private func resetDataFromPreviousRecording(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Reset all data from previous recording
      try self.recorder.reset()
      self.tape = try AKAudioFile()

      // Completed without error
      onSuccess(true)
    } catch {
      print("Failed.")

      // Aborted with error
      self.jsonArray["error"].stringValue = error.localizedDescription
      onError(error)
    }
  }

  // Partially overwrites the previous tape with the content of the current tape
  private func overwritePartially(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // The tape which should be overwritten
      let previousTape = try AKAudioFile(forReading: URL(string: self.fileToOverwrite)!)

      // The first sample to be extracted
      var firstSampleToExtract = 0

      // The last sample to be extracted
      var lastSampleToExtract = previousTape.sampleRate * self.pointToOverwriteRecordingInSeconds

      // Extract the first part of the previous file (starting from zero to the point from which should be overwritten
      let previousTapeExtractedBefore = try previousTape.extracted(fromSample: Int64(firstSampleToExtract), toSample: Int64(lastSampleToExtract))

      // Append the the first part of the previous tape to the final tape
      var newFile = try self.finalTape?.appendedBy(file: previousTapeExtractedBefore)
      self.finalTape = newFile

      // Append the new recorded tape (the part which replaces the old part in the previous file)
      newFile = try self.finalTape?.appendedBy(file: self.tape)
      self.finalTape = newFile

      // The first sample to be extracted
      firstSampleToExtract = Int(((self.finalTape?.sampleRate)! * (self.finalTape?.duration)!) + 1)

      // The last sample to be extracted
      lastSampleToExtract = previousTape.sampleRate * previousTape.duration

      // Extract the first part of the previous file (starting from zero to the point from which should be overwritten
      let previousTapeExtractedAfter = try previousTape.extracted(fromSample: Int64(firstSampleToExtract), toSample: Int64(lastSampleToExtract))

      // Append the last part of the previous tape to the final tape
      newFile = try self.finalTape?.appendedBy(file: previousTapeExtractedAfter)
      self.finalTape = newFile

      // Completed without error
      onSuccess(true)
    } catch {
      print("Failed.")

      // Aborted with error
      self.jsonArray["error"].stringValue = error.localizedDescription
      onError(error)
    }
  }

  // Deletes the file so that it can be replaced without problems
  private func deleteFile(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    // Delete the previous file
    do {
      let filemanager = FileManager.default
      let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
      let destinationPath = documentsPath.appendingPathComponent(self.fileToOverwrite)

      try filemanager.removeItem(atPath: destinationPath)

      // Completed without error
      onSuccess(true)
    } catch {
      // Success is okay here because we just need to delete the file if AudioKit didn't do it by itself
      // and if it already did an error will occur here that it cannot deleted anymore so it's ok to just move on
      onSuccess(true)
    }
  }

  // Creates one final tape out of others and stores it as an audio file on the device's storage
  private func createAndStoreTapeFromRecordings(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    // Create a new file
    if (!self.isOverwriting) {
      // Set the final tape to the current recorded tape
      self.finalTape = self.tape

      // Clear the waveform after recording
      self.currentView?.clearWaveform()

      // Store the audio data as file on the storage
      exportFinalTapeToFile(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      // Reset the final tape to be ready for the next session
      setupFinalTape(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      // Make the file url available to React Native
      if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        // Set the file url of the last recorded file
        self.jsonArray["value"]["fileUrl"].stringValue = documentsPathString + "/" + self.fileName
      }
        
      // Set the file duration in JSON
      self.jsonArray["value"]["fileDurationInMs"].stringValue = String(format: "%.0f", self.tape.duration * 1000)

      // Reset everything from previous recording
      resetDataFromPreviousRecording(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      onSuccess(true)
    } else { // Overwrite from - to
      // Overwrite the previous tape partially with the content of the current tape
      overwritePartially(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      // Clear the waveform after recording
      self.currentView?.clearWaveform()

      // Store the audio data as file on the storage
      deleteFile(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      // Store the audio data as file on the storage
      exportFinalTapeToFile(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
        
      // Set the file duration in JSON
      self.jsonArray["value"]["fileDurationInMs"].stringValue = String(format: "%.0f", (self.finalTape?.duration)! * 1000)

      // Reset the final tape to be ready for the next session
      setupFinalTape(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      // Make the file url available to React Native
      if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        // Set the file url of the last recorded file
        self.jsonArray["value"]["fileUrl"].stringValue = documentsPathString + "/" + self.fileName
      }

      // Reset everything from previous recording
      resetDataFromPreviousRecording(
        onSuccess: { success in
          self.jsonArray["success"] = true
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )

      onSuccess(true)
    }
  }

  // Instantiates all the things needed for recording
  @objc public func setupRecorder(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Define the error storage
    var e : Error?;
    
    // Cleanup before initialize the new session
    cleanupRecorder(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false
        e = error
      }
    )

    // Init a new recording session
    initRecorderSession(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false
        e = error
      }
    )

    // Setup the virtual devices e. g. mixer
    setupVirtualDevices(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false
        e = error
      }
    )

    // Start the AudioKit engine
    startEngine(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false

        e = error
      }
    )

    // Setup the final tape
    setupFinalTape(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false
        //reject("Error", self.jsonArray.rawString(), error)
        e = error
      }
    )

    // Microphone monitoring is muted
    self.micBooster.gain = 0

    // Initialize the waveform
    self.currentView?.setupWaveform(microphoneTracker: self.microphoneTracker);

    if (e == nil)  {
      // Recorder setup finished without errors
      resolve(self.jsonArray.rawString());
    } else {
      // Recorder setup finished with errors
      reject("Error", self.jsonArray.rawString(), e)
    }
  }

  // Starts the recording of audio
  @objc public func startRecording(_ startTimeInMs:Double, file filePath:NSString, resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Microphone will be monitored while recording
    // only if headphones are plugged
    if AKSettings.headPhonesPlugged {
      self.micBooster.gain = 1
    }

    // If -1 then overwriting flag is set to false, "first" new recording
    // otherwise set overwriting flag to true, prepare overwriting from specific point
    if (startTimeInMs >= 0 && filePath != "") {
      self.isOverwriting = true
      self.pointToOverwriteRecordingInSeconds = Double(startTimeInMs) / Double(1000)
      self.fileToOverwrite = filePath as String
    } else {
      self.isOverwriting = false
    }

    do {
      // Reset all data from previous recording
      try self.recorder.reset()

      // Try to start recording
      try self.recorder.record()

      // Start rendering the waveform
      self.currentView?.resumeWaveform()

      // Inform bridge/React about success
      self.jsonArray["success"] = true
      resolve(self.jsonArray.rawString());
    } catch {
      print("Recording failed.")

      // Inform bridge/React about error
      self.jsonArray["error"].stringValue = error.localizedDescription
      self.jsonArray["success"] = false
      reject("Error", self.jsonArray.rawString(), error)
    }
  }

  // Stops audio recording and stores the recorded data in a file
  @objc public func stopRecording(_ resolve:@escaping RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Define the error storage
    var e : Error?;
    
    // Microphone monitoring is muted
    self.micBooster.gain = 0

    // Stop the recorder
    self.recorder.stop()

    // Stop rendering the waveform
    self.currentView?.pauseWaveform()

    // Clear the waveform after recording
    self.currentView?.clearWaveform()

    // Temporarily store the audio file recorded by the recorder
    self.tape = self.recorder.audioFile!

    // Create tape from and store the recorded audio data
    createAndStoreTapeFromRecordings(
      onSuccess: { success in
        self.jsonArray["success"] = true
      },
      onError: { error in
        self.jsonArray["success"] = false
        e = error
      }
    )
    
    if (e == nil)  {
      // Recorder stopping finished without errors
      resolve(self.jsonArray.rawString());
    } else {
      // Recorder stopping finished with errors
      reject("Error", self.jsonArray.rawString(), e)
    }
  }
}
