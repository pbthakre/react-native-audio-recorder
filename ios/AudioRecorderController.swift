//
//  AudioRecorderViewController.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 05.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

import Foundation
import UIKit

import AudioKit
import AudioKitUI
import SwiftyJSON

@objc(AudioRecorderController)
open class AudioRecorderController : NSObject {
  var micMixer: AKMixer!
  var recorder: AKNodeRecorder!
  var player: AKPlayer!
  var tape: AKAudioFile!
  var micBooster: AKBooster!
  var moogLadder: AKMoogLadder!
  var delay: AKDelay!
  var mainMixer: AKMixer!
  
//  var frequencyTracker: AKFrequencyTracker!
//  var silence: AKBooster!
  
  var audioInputPlot: EZAudioPlot!
  
  let mic = AKMicrophone()
  
//  func setupPlot() {
//    let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
//    plot.plotType = .rolling
//    plot.shouldFill = true
//    plot.shouldMirror = true
//    plot.color = UIColor.blue
//    audioInputPlot.addSubview(plot)
//  }
//  
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
    
    // Clean tempFiles !
    AKAudioFile.cleanTempDirectory()
    
    // Session settings
    AKSettings.bufferLength = .medium
    
    do {
      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
    } catch {
      AKLog("Could not set session category.")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
    
    AKSettings.defaultToSpeaker = true
    
    // Patching
    micMixer = AKMixer(mic)
    micBooster = AKBooster(micMixer)
    
    frequencyTracker = AKFrequencyTracker.init(mic, hopSize: 200, peakCount: 2000)
    silence = AKBooster(frequencyTracker, gain: 0)
    
    // Will set the level of microphone monitoring
    micBooster.gain = 0
    recorder = try? AKNodeRecorder(node: micMixer)
    
    if let file = recorder.audioFile {
      player = AKPlayer(audioFile: file)
    }
    player.isLooping = true
    
    moogLadder = AKMoogLadder(player)
    
    mainMixer = AKMixer(moogLadder, micBooster)
    
    AudioKit.output = mainMixer
    do {
      try AudioKit.start()
    } catch {
      AKLog("AudioKit did not start!")
      
      // Inform bridge/React about error
      jsonArray["success"] = false
      jsonArray["error"].stringValue = error.localizedDescription
      reject("Error", jsonArray.rawString(), error)
    }
    
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
    tape = recorder.audioFile!
    player.load(audioFile: tape)
    
    if let _ = player.audioFile?.duration {
      recorder.stop()
      
      let fileName = UUID().uuidString + ".m4a"
      
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
    
    player.stop()
    
    // Inform bridge/React about success
    resolve(jsonArray.rawString());
  }
}
