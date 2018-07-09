//
//  AudioRecorderViewController.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 05.07.18.
//  Copyright © 2018 Facebook. All rights reserved.
//

// This file is the swift file for Native UI Controller of Audio Recorder

import AudioKit
import Foundation
// import AudioKitUI
import UIKit

class AudioRecorderViewController: UIViewController {
//
//  var micMixer: AKMixer!
//  var recorder: AKNodeRecorder!
//  var player: AKPlayer!
//  var tape: AKAudioFile!
//  var micBooster: AKBooster!
//  var moogLadder: AKMoogLadder!
//  var delay: AKDelay!
//  var mainMixer: AKMixer!
//  
//  let mic = AKMicrophone()
//  
//  var state = State.readyToRecord
//  
//  enum State {
//    case readyToRecord
//    case recording
//    case readyToPlay
//    case playing
//    
//  }
//
  
  @objc func sayHello() -> Void {
    print("hello");
  }
  
  // func viewDidLoad() {
  //  super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
//    setupButtonNames()
//
//    // Clean tempFiles !
//    AKAudioFile.cleanTempDirectory()
//
//    // Session settings
//    AKSettings.bufferLength = .medium
//    
//    do {
//      try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
//    } catch {
//      AKLog("Could not set session category.")
//    }
//
//    AKSettings.defaultToSpeaker = true
//
//    // Patching
//    //inputPlot.node = mic
//    micMixer = AKMixer(mic)
//    micBooster = AKBooster(micMixer)
//
//    // Will set the level of microphone monitoring
//    micBooster.gain = 0
//    recorder = try? AKNodeRecorder(node: micMixer)
//    if let file = recorder.audioFile {
//      player = AKPlayer(audioFile: file)
//    }
//    player.isLooping = true
//    player.completionHandler = playingEnded
//
//    moogLadder = AKMoogLadder(player)
//
//    mainMixer = AKMixer(moogLadder, micBooster)
//
//    AudioKit.output = mainMixer
//    do {
//      try AudioKit.start()
//    } catch {
//      AKLog("AudioKit did not start!")
//    }
//
//    setupUIForRecording()
//  }
//
//  // CallBack triggered when playing has ended
//  // Must be seipatched on the main queue as completionHandler
//  // will be triggered by a background thread
//  func playingEnded() {
//    DispatchQueue.main.async {
//      self.setupUIForPlaying ()
//    }
//  }
//  
//  struct Constants {
//    static let empty = ""
//  }
//  
//  func setupButtonNames() {
//    // resetButton.setTitle(Constants.empty, for: UIControlState.disabled)
//    // mainButton.setTitle(Constants.empty, for: UIControlState.disabled)
//    // loopButton.setTitle(Constants.empty, for: UIControlState.disabled)
//  }
//  
//  func setupUIForRecording () {
//    state = .readyToRecord
//    // infoLabel.text = "Ready to record"
//    // mainButton.setTitle("Record", for: .normal)
//    // resetButton.isEnabled = false
//    // resetButton.isHidden = true
//    micBooster.gain = 0
//    setSliders(active: false)
//  }
//  
//  func setupUIForPlaying () {
//    let recordedDuration = player != nil ? player.audioFile?.duration  : 0
//    // infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration!)) seconds"
//    // mainButton.setTitle("Play", for: .normal)
//    state = .readyToPlay
//    // resetButton.isHidden = false
//    // resetButton.isEnabled = true
//    setSliders(active: true)
//    // frequencySlider.value = moogLadder.cutoffFrequency
//    // resonanceSlider.value = moogLadder.resonance
//  }
//  
//  func setSliders(active: Bool) {
//    // loopButton.isEnabled = active
//    // moogLadderTitle.isEnabled = active
//    // frequencySlider.callback = updateFrequency
//    // frequencySlider.isHidden = !active
//    // resonanceSlider.callback = updateResonance
//    // resonanceSlider.isHidden = !active
//    // frequencySlider.range = 10 ... 2_000
//    // moogLadderTitle.text = active ? "Moog Ladder Filter" : Constants.empty
//  }
//
//  func updateFrequency(value: Double) {
//    moogLadder.cutoffFrequency = value
//    // frequencySlider.property = "Frequency"
//    // frequencySlider.format = "%0.0f"
//  }
//  
//  func updateResonance(value: Double) {
//    moogLadder.resonance = value
//    // resonanceSlider.property = "Resonance"
//    // resonanceSlider.format = "%0.3f"
//  }
//  
//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//  }
}
