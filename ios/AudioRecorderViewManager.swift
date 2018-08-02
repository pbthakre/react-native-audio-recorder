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
    currentView = newView
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
      jsonArray["error"].stringValue = error.localizedDescription + " - Cleanup failed."
      onError(error)
    }
  }
  
  // Init new recording session
  private func initRecorderSession(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Create a session with recording/recording and bluetooth output only
      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
      
      // Session settings
      // Set number of audio frames which can be hold by the buffer (medium = 8)
      AKSettings.bufferLength = .medium
      
      // Use default speakers of the device
      AKSettings.defaultToSpeaker = true
      
      //throw TestError.runtimeError("some message")
      
      // Completed without error
      onSuccess(true)
    } catch {
      // Return with error
      AKLog("Init of session failed.")
      jsonArray["error"].stringValue = error.localizedDescription + " - Init of session failed."
      onError(error)
    }
  }
  
  // Setup virtual devices like, for example, mixer
  private func setupVirtualDevices(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Setup mixer (input handler) for microphone, plus wrap mixer into booster (property handler)
      micMixer = AKMixer(mic)
      micBooster = AKBooster(micMixer)
      
      // Microphone monitoring is muted
      micBooster.gain = 0
      
      // Setup recorder with using microphone mixer as input handler
      recorder = try AKNodeRecorder(node: micMixer)
      
      // Setup player using the recorded audio file
      if let file = recorder.audioFile {
        player = AKPlayer(audioFile: file)
      }
      
      // Apply filter which enables to manipulate the signal
      moogLadder = AKMoogLadder(player)
      moogLadder.presetDullNoiseMoogLadder()
      
      // Create a mixer which combines our filtered node and our microphone node
      mainMixer = AKMixer(moogLadder, micBooster)
      
      // Completed without error
      onSuccess(true)
    } catch {
      // Return with error
      AKLog("Setup of virtual devices failed.")
      jsonArray["error"].stringValue = error.localizedDescription + " - Setup of virtual devices failed."
      onError(error)
    }
  }
  
  // Start the AudioKit engine
  private func startEngine(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Set the signal of the main mixer as output signal
      AudioKit.output = mainMixer
      
      // Start the audio engine
      try AudioKit.start()
      
      // Completed without error
      onSuccess(true)
    } catch {
      // Return with error
      AKLog("Starting of engine failed.")
      jsonArray["error"].stringValue = error.localizedDescription + " - Starting of engine failed."
      onError(error)
    }
  }
  
  // Setup the final tape which will contain all audio data of one session
  private func setupFinalTape(onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      // Setup the audio tape which will contain the compilation of all the audio data of one session
      finalTape = try AKAudioFile()
      
      // Completed without error
      onSuccess(true)
    }
    catch {
      // Return with error
      AKLog("Setup of final tape failed.")
      jsonArray["error"].stringValue = error.localizedDescription + " - Setup of final tape failed."
      onError(error)
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
    
    // Start the AudioKit engine
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
    micBooster.gain = 0

    // Initialize the waveform
    self.currentView?.setupWaveform(mic: self.mic);
    
    // Recorder setup finished without errors
    resolve(jsonArray.rawString());
  }

  // Starts the recording of audio
  @objc public func startRecording(_ startTimeInMs:Double, resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Microphone will be monitored while recording
    // only if headphones are plugged
    if AKSettings.headPhonesPlugged {
      micBooster.gain = 1
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
      try recorder.reset()
      
      // Try to start recording
      try recorder.record()
      
      // Set input node to microphone for recording
      self.currentView?.setNode(inputNode: mic)
      
      // Start rendering the waveform
      self.currentView?.resumeWaveform()
      
      // Inform bridge/React about success
      jsonArray["success"] = true
      resolve(jsonArray.rawString());
    } catch {
      print("Recording failed.")
      
      // Inform bridge/React about error
      jsonArray["error"].stringValue = error.localizedDescription
      jsonArray["success"] = false
      reject("Error", jsonArray.rawString(), error)
    }
  }
  @objc public func stopRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Microphone monitoring is muted
    micBooster.gain = 0
    
    // Stop the recorder
    recorder.stop()
    
    // Stop rendering the waveform
    self.currentView?.pauseWaveform()
    
    // Temporarily store the audio file recorded by the recorder
    tape = recorder.audioFile!
    
    // Create a new file
    if (!self.isOverwriting) {
      // Append the current recorded tape to the final tape
      do {
        let newFile = try finalTape?.appendedBy(file: tape)
        finalTape = newFile
      }
      catch {
        // Inform bridge/React about error
        jsonArray["success"] = false
        jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", jsonArray.rawString(), error)
      }
      
      // Clear the waveform after recording
      self.currentView?.clearWaveform()
      
      // Store the audio data (final tape) permanently on the device's storage
      finalTape?.exportAsynchronously(name: fileName,
                                      baseDir: .documents,
                                      exportFormat: .m4a) {_, exportError in
                                        if let error = exportError {
                                          print("Export Failed \(error)")
                                          
                                          // Inform bridge/React about error
                                          self.jsonArray["success"] = false
                                          self.jsonArray["error"].stringValue = error.localizedDescription
                                          reject("Error", self.jsonArray.rawString(), error)
                                        } else {
                                          print("Export succeeded")
                                        }
      }
      
      // Reset the final tape to be ready for the next session
      do {
        finalTape = try AKAudioFile()
      }
      catch {
        // Inform bridge/React about error
        jsonArray["success"] = false
        jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", jsonArray.rawString(), error)
      }
      
      // Make the file url available to React Native
      if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        // Set the file url of the last recorded file
        jsonArray["value"]["fileUrl"].stringValue = documentsPathString + "/" + fileName
      }
      
      do {
        // Reset all data from previous recording
        try recorder.reset()
        tape = try AKAudioFile()
      } catch {
        print("Errored recording.")
        
        // Inform bridge/React about error
        jsonArray["success"] = false
        jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", jsonArray.rawString(), error)
      }
    } else { // Overwrite from - to
      do {
        // The tape which should be overwritten
        let previousTape = try AKAudioFile(readFileName: fileName, baseDir: .documents)
        
        // The first sample to be extracted
        var firstSampleToExtract = 0
        
        // The last sample to be extracted
        var lastSampleToExtract = previousTape.sampleRate * pointToOverwriteRecordingInSeconds
        
        // Extract the first part of the previous file (starting from zero to the point from which should be overwritten
        let previousTapeExtractedBefore = try previousTape.extracted(fromSample: Int64(firstSampleToExtract), toSample: Int64(lastSampleToExtract))
        
        // Append the the first part of the previous tape to the final tape
        var newFile = try finalTape?.appendedBy(file: previousTapeExtractedBefore)
        finalTape = newFile
        
        // Append the new recorded tape (the part which replaces the old part in the previous file)
        newFile = try finalTape?.appendedBy(file: tape)
        finalTape = newFile
        
        // The first sample to be extracted
        firstSampleToExtract = Int((tape.sampleRate * tape.duration) + 1)
        
        // The last sample to be extracted
        lastSampleToExtract = previousTape.sampleRate * previousTape.duration
        
        // Extract the first part of the previous file (starting from zero to the point from which should be overwritten
        let previousTapeExtractedAfter = try previousTape.extracted(fromSample: Int64(firstSampleToExtract), toSample: Int64(lastSampleToExtract))
        
        // Append the last part of the previous tape to the final tape
        newFile = try finalTape?.appendedBy(file: previousTapeExtractedAfter)
        finalTape = newFile
        
        // Clear the waveform after recording
        self.currentView?.clearWaveform()
        
        // Store the audio data (final tape) permanently on the device's storage
        finalTape?.exportAsynchronously(name: fileName,
                                        baseDir: .documents,
                                        exportFormat: .m4a) {_, exportError in
                                          if let error = exportError {
                                            print("Export Failed \(error)")
                                            
                                            // Inform bridge/React about error
                                            self.jsonArray["success"] = false
                                            self.jsonArray["error"].stringValue = error.localizedDescription
                                            reject("Error", self.jsonArray.rawString(), error)
                                          } else {
                                            print("Export succeeded")
                                          }
        }
        
        // Reset the final tape to be ready for the next session
        finalTape = try AKAudioFile()
        
        // Make the file url available to React Native
        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
          // Set the file url of the last recorded file
          jsonArray["value"]["fileUrl"].stringValue = documentsPathString + "/" + fileName
        }
        
        // Reset all data from previous recording
        try recorder.reset()
        tape = try AKAudioFile()
      } catch {
        print("Errored.")
        
        // Inform bridge/React about error
        jsonArray["success"] = false
        jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", jsonArray.rawString(), error)
      }
    }
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }
}
