//
//  AudioRecorderViewManager.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 07.08.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

import Foundation
import UIKit

import AudioKit
import AudioKitUI

// Represents the AudioPlayerViewManager which manages our AudioPlayerView Module
@objc(AudioPlayerViewManager)
class AudioPlayerViewManager : RCTViewManager {
  // The native ui view
  private var currentView: AudioPlayerView?
  
  // The promise response
  private var jsonArray: JSON = [
    "success": false,
    "error": "",
    "value": ["fileUrl": ""]
  ]
  
  // Instantiates the view
  override func view() -> AudioPlayerView {
    // Turn off application exit on error of audio file reading in EZAudioUtilities (AudioKit)
    AudioPlayerHelper.setShouldExitOnCheckResultFail()
  
    let newView = AudioPlayerView()
    self.currentView = newView
    self.currentView?.setupWaveform()
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
  
  // Enables to re-run a method x-times or until a condition is fullfilled
  func retry(_ attempts: Int, task: @escaping (_ onSuccess: @escaping (Bool) -> Void, _ onError: @escaping (Error) -> Void) -> Void, onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    // Try
    task({(success) in
      // Condition fullfilled
      onSuccess(success)
    }) {(error) in
      // Error
      print("Error retry left \(attempts)")
      
      // Attempts left
      if attempts > 1 {
        // Wait x seconds before retrying
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.retry(attempts - 1, task: task, onSuccess: onSuccess, onError: onError)
        }
      } else {
        onError(error)
      }
    }
  }
  
  // Render a waveform from audio file data
  @objc public func renderByFile(_ fileUrl:String, resolver resolve:@escaping RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    
    // Try X-times to create waveform from audio file, this retry is necessary since writing the file
    // is not always finished when file access to read is done
    self.retry(10, task: { success, onError in
      self.currentView?.updateWaveformWithData(fileUrl: URL(string: fileUrl)!, onSuccess: success, onError: onError) },
      onSuccess: { success in
        self.jsonArray["success"] = true
        resolve(self.jsonArray.rawString());
      },
      onError: { error in
        self.jsonArray["success"] = false
        self.jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", self.jsonArray.rawString(), error)
      })
  }
}
