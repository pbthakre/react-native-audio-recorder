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
  
  // 0: notReady
  // 1: readyToRecord
  // 2: recording
  // 3: readyToPlay
  // 4: playing
  var state: Int = 0;
  
  // Access AudioRecorderBridge to send events to React
  let myAudioRecorderBridge: AudioRecorderBridge = AudioRecorderBridge();
  
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
    if let file = recorder.audioFile {
      player = AKPlayer(audioFile: file)
    }
    player.isLooping = true
    player.completionHandler = playingEnded
    
    moogLadder = AKMoogLadder(player)
    
    mainMixer = AKMixer(moogLadder, micBooster)
    
    AudioKit.output = mainMixer
    do {
      try AudioKit.start()
    } catch {
      AKLog("AudioKit did not start!")
    }
    
    setupForRecording()
  }
  
  // CallBack triggered when playing has ended
  // Must be seipatched on the main queue as completionHandler
  // will be triggered by a background thread
  func playingEnded() {
    DispatchQueue.main.async {
      self.setupForPlaying ()
    }
  }
  
  @objc func triggerRecorderEvent() {
    switch state {
    case 1:
      // microphone will be monitored while recording
      // only if headphones are plugged
      if AKSettings.headPhonesPlugged {
        micBooster.gain = 1
      }
      
      do {
        try recorder.record();
        state = 2
        myAudioRecorderBridge.recorderStateChanged(to: 2);
      } catch {
        print("Errored recording.")
      }
    case 2:
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
                                    } else {
                                      print("Export succeeded")
                                    }
        }
        
        setupForPlaying()
        
        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
          // Send the file url of the last recorded file to react native
          myAudioRecorderBridge.lastRecordedFileUrlChanged(to: documentsPathString + fileName)
        }
      }
    case 3:
      player.play()
      state = 4
      myAudioRecorderBridge.recorderStateChanged(to: 4);
    case 4:
      player.stop()
      setupForRecording()
    default:
      state = 1
      myAudioRecorderBridge.recorderStateChanged(to: 1);
    }
  }
  
  struct Constants {
    static let empty = ""
  }
  
  func setupForRecording () {
    state = 1
    myAudioRecorderBridge.recorderStateChanged(to: 1);
    micBooster.gain = 0
  }
  
  func setupForPlaying () {
    state = 3
    myAudioRecorderBridge.recorderStateChanged(to: 3);
  }
  
//  func resetButtonTouched(sender: UIButton) {
//    player.stop()
//    do {
//      try recorder.reset()
//    } catch { print("Errored resetting.") }
//
//    // try? player.replaceFile((recorder.audioFile)!)
//    setupForRecording()
//  }
}
