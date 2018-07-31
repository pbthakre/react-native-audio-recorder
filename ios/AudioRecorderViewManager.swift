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
  // Represents the device's microphone
  private let mic = AKMicrophone()
  
   // Represents the mixer which handles the microphone input
  private var micMixer: AKMixer!
  
  // Represents the mixer which handles the speaker output
  private var mainMixer: AKMixer!
  
  // Represents the recorder which handles recording of audio samples via mixer
  private var recorder: AKNodeRecorder!
  
  // Represents the player which handles playing of audio samples via mixer
  private var player: AKPlayer!
  
  // Represents the file of recorded or played audio samples
  private var tape: AKAudioFile!
  
  // The name of the file where the current recording is stored in
  private let fileName = "currentRecording.m4a"
  
  // Represents the booster which lets control the microphone input properties such as volume
  private var micBooster: AKBooster!
  
  // Represents the filter node
  private var moogLadder: AKMoogLadder!
  
  // Represents the view
  private var currentView : AudioRecorderView?
  
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

  @objc public func setupRecorder(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Stop AudioKit to prevent errors of duplicate initialization
    do {
      try AudioKit.stop()
    } catch {
      AKLog("AudioKit did not stop!")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
    
    // Remove temporary files from temp directory
    AKAudioFile.cleanTempDirectory()
    
    // Session settings
    // Set number of audio frames which can be hold by the buffer (medium = 8)
    AKSettings.bufferLength = .medium
    
    do {
      // Create a session with recording/recording and bluetooth output only
      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
    } catch {
      AKLog("Could not set session category.")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
    
    // Use default speakers of the device
    AKSettings.defaultToSpeaker = true
    
    // Setup mixer (input handler) for microphone, plus wrap mixer into booster (property handler)
    micMixer = AKMixer(mic)
    micBooster = AKBooster(micMixer)
    
    // Microphone monitoring is muted
    micBooster.gain = 0
    
    // Setup recorder with using microphone mixer as input handler
    recorder = try? AKNodeRecorder(node: micMixer)
    
    // Setup player using the recorded audio file
    if let file = recorder.audioFile {
      player = AKPlayer(audioFile: file)
    }
    
    // Define if the player should play the audio file again after finishing
    player.isLooping = true
    
    // Apply filter which enables to manipulate the signal
    moogLadder = AKMoogLadder(player)
    moogLadder.presetDullNoiseMoogLadder()
    
    // Create a mixer which combines our filtered node and our microphone node
    mainMixer = AKMixer(moogLadder, micBooster)
    
    // Set the signal of the main mixer as output signal
    AudioKit.output = mainMixer
    do {
      // Start the audio engine
      try AudioKit.start()
    } catch {
      AKLog("AudioKit did not start!")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
    
    // Microphone monitoring is muted
    micBooster.gain = 0
    
    // Initialize the wave form
    self.currentView?.setupWaveform(mic: self.mic);
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }

  @objc public func startRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Microphone will be monitored while recording
    // only if headphones are plugged
    if AKSettings.headPhonesPlugged {
      micBooster.gain = 1
    }
    
    do {
      // Reset all data from previous recording
      try recorder.reset()
      
      // Try to start recording
      try recorder.record()
      
      // Set input node to microphone for recording
      self.currentView?.setNode(inputNode: mic)
      
      // Clear the waveform before playing
      self.currentView?.clearWaveform()
      
      // Start rendering the waveform
      self.currentView?.resumeWaveform()
      
      // Inform bridge/React about success
      resolve(jsonArray.rawString());
    } catch {
      print("Errored recording.")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
  }

  @objc public func stopRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ["lastRecordedFilePath": ""]
    ]
    
    // Microphone monitoring is muted
    micBooster.gain = 0
    
    // Temporarily store the audio file recorded by the recorder
    tape = recorder.audioFile!
    
    // Load the audio samples from the file into the player
    player.load(audioFile: tape)
    
    // Check if the loaded audio file has a duration and is therefore valid from that point of view
    if let _ = player.audioFile?.duration {
      // Stop the recorder
      recorder.stop()
      
      // Stop rendering the waveform
      self.currentView?.pauseWaveform()
      
      // Clear the waveform after recording
      self.currentView?.clearWaveform()
      
      // Store the audio data permanently on the device's storage
      tape.exportAsynchronously(name: fileName,
                                baseDir: .documents,
                                exportFormat: .m4a) {_, exportError in
                                  if let error = exportError {
                                    print("Export Failed \(error)")
                                    
                                    // Inform bridge/React about error
                                    jsonArray["success"] = false
                                    jsonArray["error"].stringValue = error.localizedDescription
                                    reject("Error", jsonArray.rawString(), error)
                                  } else {
                                    print("Export succeeded")
                                  }
      }
      
      // Make the file url available to React Native
      if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        // Set the file url of the last recorded file
        jsonArray["value"]["lastRecordedFilePath"].stringValue = documentsPathString + fileName
      }
    }
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }

  @objc public func startPlaying(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Set main mixer as input to render waveform from played audio
    self.currentView?.setNode(inputNode: mainMixer)
    
    // Clear the waveform before playing
    self.currentView?.clearWaveform()
    
    // Start rendering waveform of played audio
    self.currentView?.resumeWaveform()
    
    // Load audio file data into player
    if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
      do {
        try player.load(url: NSURL(string: documentsPathString + "/" + fileName)! as URL)
      } catch {
        print("Errored recording.")
        
        // Inform bridge/React about error
        jsonArray["success"] = false
        jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", jsonArray.rawString(), error)
      }
    }
    
    // Start playing the audio file
    player.play()
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }

  @objc public func stopPlaying(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Stop rendering the waveform
    self.currentView?.pauseWaveform()
    
    // Clear the waveform after playing
    self.currentView?.clearWaveform()
    
    // Stop playing the audio file
    player.stop()
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }
}
