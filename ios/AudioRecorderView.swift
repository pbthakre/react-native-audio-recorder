//
//  SampleView.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Crowdio GmbH. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

// Represents the our native ui (view) component
class AudioRecorderView: EZAudioPlot {
  var audioInputPlot: EZAudioPlot!
  let mic = AKMicrophone()
  
  private override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.frame = frame
    self.autoresizingMask = [.flexibleWidth]

    let plot = AKNodeOutputPlot(self.mic, frame: frame)
    plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    plot.plotType = .rolling
    plot.shouldFill = true
    plot.shouldMirror = true
    plot.color = UIColor.red
    self.addSubview(plot)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
