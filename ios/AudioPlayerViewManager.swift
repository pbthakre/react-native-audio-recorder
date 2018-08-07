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
import SwiftyJSON

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
    let newView = AudioPlayerView()
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
  
  // Instantiates all the things needed for the player waveform
  @objc public func renderByFile(_ fileUrl:String, resolver resolve:@escaping RCTPromiseResolveBlock, rejecter reject:@escaping RCTPromiseRejectBlock) {
    
    // Create the waveform from file
    self.currentView?.setupWaveform(
      fileUrl: URL(string: fileUrl)!,
      onSuccess: { success in
        if (success) {
          self.jsonArray["success"] = true
          resolve(self.jsonArray.rawString());
        }
      },
      onError: { error in
        self.jsonArray["success"] = false
        self.jsonArray["error"].stringValue = error.localizedDescription
        reject("Error", self.jsonArray.rawString(), error)
      }
    )
  }
}
