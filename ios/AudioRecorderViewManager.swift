//
//  AudioRecorderViewManager.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Crowdio GmbH. All rights reserved.
//

import Foundation
import UIKit

import AudioKit
import AudioKitUI
import SwiftyJSON

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
  private let fileName = "currentRecording.m4a"
  
  // The booster which lets control the microphone input properties such as volume
  private var micBooster: AKBooster!
  
  // The filter node
  private var moogLadder: AKMoogLadder!
  
  // The native ui view
  private var currentView: AudioRecorderView?
  
  // The position from which to overwrite the recorded data
  private var pointToOverwriteRecordingInSeconds: Double = 0.00
  
  // Defines if the recording is/should be overwriting existing parts of the file
  private var isOverwriting: Bool = false
  
  // The promise response
  private var jsonArray: JSON = [
    "success": false,
    "error": "",
    "value": ["fileUrl": ""]
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
      AKSettings.defaultToSpeaker = false
      
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
  
  // Appends the current recorded audio to the final audio
  private func appendCurrentTapeToFinalTape(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Append the current recorded tape to the final tape
      let newFile = try self.finalTape?.appendedBy(file: self.tape)
      self.finalTape = newFile
      
      // Completed without error
      onSuccess(true)
    }
    catch {
      // Aborted with error
      AKLog("Failed")
      self.jsonArray["error"].stringValue = error.localizedDescription
      onError(error)
    }
  }
  
  // Exports the final tape to a file
  private func exportFinalTapeToFile(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    // Store the audio data (final tape) permanently on the device's storage
    self.finalTape?.exportAsynchronously(
      name: self.fileName,
      baseDir: .documents,
      exportFormat: .m4a) {_, exportError in
        if let error = exportError {
          print("Export failed.")
          
          // Aborted with error
          self.jsonArray["error"].stringValue = error.localizedDescription + " - Export failed."
          onError(error)
        } else {
          print("Export succeeded.")
          // Completed without error
          onSuccess(true)
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
  
  // Partially vverwrites the previous tape with the content of the current tape
  private func overwritePartially(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // The tape which should be overwritten
      let previousTape = try AKAudioFile(readFileName: self.fileName, baseDir: .documents)
      
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
      firstSampleToExtract = Int((self.tape.sampleRate * self.tape.duration) + 1)
      
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
  
  // Creates one final tape out of others and stores it as an audio file on the device's storage
  private func createAndStoreTapeFromRecordings(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    // Create a new file
    if (!self.isOverwriting) {
      // Append the last recorded audio to the final tape
      appendCurrentTapeToFinalTape(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
      
      // Clear the waveform after recording
      self.currentView?.clearWaveform()
      
      // Store the audio data as file on the storage
      exportFinalTapeToFile(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
      
      // Reset the final tape to be ready for the next session
      setupFinalTape(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
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
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
    } else { // Overwrite from - to
      // Overwrite the previous tape partially with the content of the current tape
      overwritePartially(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
      
      // Clear the waveform after recording
      self.currentView?.clearWaveform()
      
      // Store the audio data as file on the storage
      exportFinalTapeToFile(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
      
      // Reset the final tape to be ready for the next session
      setupFinalTape(
        onSuccess: { success in
          if (success) {
            self.jsonArray["success"] = true
          }
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
          if (success) {
            self.jsonArray["success"] = true
          }
        },
        onError: { error in
          self.jsonArray["success"] = false
          onError(error)
        }
      )
    }
  }

  // Instantiates all the things needed for recording
  @objc public func setupRecorder(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Cleanup before initialize the new session
    cleanupRecorder(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Init a new recording session
    initRecorderSession(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Setup the virtual devices e. g. mixer
    setupVirtualDevices(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Start the AudioKit engine
    startEngine(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Setup the final tape
    setupFinalTape(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Microphone monitoring is muted
    self.micBooster.gain = 0

    // Initialize the waveform
    self.currentView?.setupWaveform(mic: self.mic);
    
    // Recorder setup finished without errors
    resolve(self.jsonArray.rawString());
  }

  // Starts the recording of audio
  @objc public func startRecording(_ startTimeInMs:Double, resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Microphone will be monitored while recording
    // only if headphones are plugged
    if AKSettings.headPhonesPlugged {
      self.micBooster.gain = 1
    }
    
    // If -1 then overwriting flag is set to false, "first" new recording
    // otherwise set overwriting flag to true, prepare overwriting from specific point
    if (startTimeInMs < 0) {
      self.isOverwriting = false
    } else {
      self.isOverwriting = true
      self.pointToOverwriteRecordingInSeconds = Double(startTimeInMs) / Double(1000)
    }
    
    do {
      // Reset all data from previous recording
      try self.recorder.reset()
      
      // Try to start recording
      try self.recorder.record()
      
      // Set input node to microphone for recording
      self.currentView?.setNode(inputNode: mic)
      
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
  @objc public func stopRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Microphone monitoring is muted
    self.micBooster.gain = 0
    
    // Stop the recorder
    self.recorder.stop()
    
    // Stop rendering the waveform
    self.currentView?.pauseWaveform()
    
    // Temporarily store the audio file recorded by the recorder
    self.tape = self.recorder.audioFile!
    
    // Create tape from and store the recorded audio data
    createAndStoreTapeFromRecordings(
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
    
    // Inform bridge/React about success
    resolve(self.jsonArray.rawString());
  }
}
