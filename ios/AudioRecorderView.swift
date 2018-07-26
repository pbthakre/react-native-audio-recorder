//
//  AudioRecorderView.swift
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
    
    // Set width to use 100% (relative)
    self.autoresizingMask = [.flexibleWidth]

    // Create the WaveForm
    let plot = AKNodeOutputPlot(self.mic, frame: frame)
    
    // Set width and height to use 100 % (relative)
    plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // Set plot properties to generate waveform like plot
    plot.plotType = .rolling
    plot.shouldFill = true
    plot.shouldMirror = true
    
    // Set the color of the line
    plot.color = UIColor.red
    
    // Set the background color of the plot
    plot.backgroundColor = UIColor.black
    
    // Set the scaling factor of the line
    plot.gain = 5
    
    // Add the view
    self.addSubview(plot)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
