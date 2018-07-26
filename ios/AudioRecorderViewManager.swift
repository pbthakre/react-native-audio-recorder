//
//  SampleViewManager.swift
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
  let mic = AKMicrophone()
  
   // Represents the mixer which handles the microphone input
  var micMixer: AKMixer!
  
  // Represents the mixer which handles the speaker output
  var mainMixer: AKMixer!
  
  // Represents the recorder which handles recording of audio samples via mixer
  var recorder: AKNodeRecorder!
  
  // Represents the player which handles playing of audio samples via mixer
  var player: AKPlayer!
  
  // Represents the file of recorded or played audio samples
  var tape: AKAudioFile!
  
  // Represents the booster which lets control the microphone input properties such as volume
  var micBooster: AKBooster!
  
  
  var moogLadder: AKMoogLadder!
  var delay: AKDelay!

  
//  var frequencyTracker: AKFrequencyTracker!
//  var silence: AKBooster!
  

  // Represents the view
  var currentView : AudioRecorderView?
  
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

//  func updateUI() {
//    var noteFrequencies = Array<Float>()
//
//    if frequencyTracker.amplitude > 0.1 {
//      // frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
//
//      var frequency = Float(frequencyTracker.frequency)
//      while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
//        frequency = frequency / 2.0
//      }
//      while (frequency < Float(noteFrequencies[0])) {
//        frequency = frequency * 2.0
//      }
//
//      var minDistance: Float = 10000.0
//      var index = 0
//
//      for i in 0..<noteFrequencies.count {
//        let distance = fabsf(Float(noteFrequencies[i]) - frequency)
//        if (distance < minDistance){
//          index = i
//          minDistance = distance
//        }
//      }
//      let octave = Int(log2f(Float(frequencyTracker.frequency) / frequency))
//      // noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
//      // noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
//    }
//    // amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
//  }

  @objc func setupRecorder(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
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
    
//    frequencyTracker = AKFrequencyTracker.init(mic, hopSize: 200, peakCount: 2000)
//    silence = AKBooster(frequencyTracker, gain: 0)
    
    // Microphone monitoring is muted
    micBooster.gain = 0
    
    // Setup recorder with using microphone mixer as input handler
    recorder = try? AKNodeRecorder(node: micMixer)
    
    // Setup player using the recorded audio file
    if let file = recorder.audioFile {
      player = AKPlayer(audioFile: file)
    }
    
    // Player should play the audio file again after finishing
    player.isLooping = true
    
    moogLadder = AKMoogLadder(player)
    
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
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }

  @objc func startRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
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
      // Try to start recording
      try recorder.record();
      
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

  @objc func stopRecording(_ resolve:RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
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
      
      // Generate a random file name
      let fileName = UUID().uuidString + ".m4a"
      
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

  @objc func startPlaying(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Start playing the audio file
    player.play()
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }

  @objc func stopPlaying(_ resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) {
    // Result/Error - Response
    var jsonArray: JSON = [
      "success": true,
      "error": "",
      "value": ""
    ]
    
    // Stop playing the audio file
    player.stop()
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }
}
