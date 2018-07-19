//
//  AudioRecorderViewController.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 05.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI
import UIKit

@objc open class AudioRecorderViewController : UIViewController {
  var micMixer: AKMixer!
  var recorder: AKNodeRecorder!
  var player: AKPlayer!
  var tape: AKAudioFile!
  var micBooster: AKBooster!
  var moogLadder: AKMoogLadder!
  var delay: AKDelay!
  var mainMixer: AKMixer!
  
  let mic = AKMicrophone()
  
  // Access AudioRecorderBridge to send events to React
  let myAudioRecorderBridge: AudioRecorderBridge = AudioRecorderBridge();
  
  let myAudioRecorderUIManager: AudioRecorderUIManager = AudioRecorderUIManager();
  
  @objc func setupRecorder() {
    // Stop AudioKit to prevent errors of duplicate initialization
    do {
      try AudioKit.stop()
    } catch {
      AKLog("AudioKit did not stop!")
    }
    
    // Clean tempFiles !
    AKAudioFile.cleanTempDirectory()
    
    // Session settings
    AKSettings.bufferLength = .medium
    
    do {
      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
    } catch {
      AKLog("Could not set session category.")
    }
    
    AKSettings.defaultToSpeaker = true
    
    // Patching
    micMixer = AKMixer(mic)
    micBooster = AKBooster(micMixer)
    
    // Will set the level of microphone monitoring
    micBooster.gain = 0
    recorder = try? AKNodeRecorder(node: micMixer)
    
    AudioKit.output = mainMixer
    do {
      try AudioKit.start()
    } catch {
      AKLog("AudioKit did not start!")
    }
    
    micBooster.gain = 0
  }
  
  @objc func startRecording() {
    myAudioRecorderUIManager.changeBackgroundColor(UIColor.green)
    // Microphone will be monitored while recording
    // only if headphones are plugged
    if AKSettings.headPhonesPlugged {
      micBooster.gain = 1
    }
    
    do {
      // Try to start recording
      try recorder.record();
      
      // Inform bridge/React about success
      myAudioRecorderBridge.isRecorderEventSuccessfull(true);
    } catch {
      print("Errored recording.")
      
      // Inform bridge/React about error
      myAudioRecorderBridge.isRecorderEventSuccessfull(false);
    }
  }
  
  @objc func stopRecording() {
    // Microphone monitoring is muted
    micBooster.gain = 0
    tape = recorder.audioFile!
    
    recorder.stop()
      
    let fileName = UUID().uuidString + ".m4a"
      
    tape.exportAsynchronously(name: fileName,
                              baseDir: .documents,
                              exportFormat: .m4a) {_, exportError in
                                if let error = exportError {
                                  print("Export Failed \(error)")
                                } else {
                                  print("Export succeeded")
                                }
    }
      
    if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
      // Send the file url of the last recorded file to react native
      myAudioRecorderBridge.lastRecordedFileUrlChanged(to: documentsPathString + fileName)
    }
  }
}
