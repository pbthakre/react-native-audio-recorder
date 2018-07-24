//
//  SampleViewManager.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(AudioRecorderViewManager)
class AudioRecorderViewManager : RCTViewManager {
  override func view() -> UIView! {
    return AudioRecorderView();
  }
}
