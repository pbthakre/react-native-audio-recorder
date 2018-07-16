//
//  AudioRecorderViewController.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 05.07.18.
//
//

// This file is the swift file for Native UI Controller of Audio Recorder

import Foundation
import AudioKit
import AudioKitUI
import UIKit

@objc open class AudioRecorderViewController: UIViewController {
  var micMixer: AKMixer!
  var recorder: AKNodeRecorder!
  var player: AKPlayer!
  var tape: AKAudioFile!
  var micBooster: AKBooster!
  var moogLadder: AKMoogLadder!
  var delay: AKDelay!
  var mainMixer: AKMixer!
  
  let mic = AKMicrophone()
  
  var state = State.readyToRecord
  
  enum State {
    case readyToRecord
    case recording
    case readyToPlay
    case playing
    
  }
  
  @objc func setupRecorder() {
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
  
  @objc func mainButtonTouched() {
    switch state {
    case .readyToRecord:
      state = .recording
      
      // microphone will be monitored while recording
      // only if headphones are plugged
      if AKSettings.headPhonesPlugged {
        micBooster.gain = 1
      }
      
      do {
        try recorder.record()
      } catch { print("Errored recording.") }
    case .recording:
      // Microphone monitoring is muted
      micBooster.gain = 0
      tape = recorder.audioFile!
      player.load(audioFile: tape)
      
      if let _ = player.audioFile?.duration {
        recorder.stop()
        tape.exportAsynchronously(name: "TempTestFile.m4a",
                                  baseDir: .documents,
                                  exportFormat: .m4a) {_, exportError in
                                    if let error = exportError {
                                      print("Export Failed \(error)")
                                    } else {
                                      print("Export succeeded")
                                    }
        }
        setupForPlaying()
      }
    case .readyToPlay:
      player.play()
      state = .playing
    case .playing:
      player.stop()
      setupForPlaying()
    }
  }
  
  struct Constants {
    static let empty = ""
  }
  
  func setupForRecording () {
    state = .readyToRecord
    micBooster.gain = 0
  }
  
  func setupForPlaying () {
    state = .readyToPlay
  }
  
  func resetButtonTouched(sender: UIButton) {
    player.stop()
    do {
      try recorder.reset()
    } catch { print("Errored resetting.") }
    
    // try? player.replaceFile((recorder.audioFile)!)
    setupForRecording()
  }
}
