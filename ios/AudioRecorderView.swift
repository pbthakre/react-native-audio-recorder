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
  var plot : AKNodeOutputPlot = AKNodeOutputPlot(AKMixer.init(), frame: CGRect.init())
  private var timelineBar = TimelineBar()
  
  private override init(frame: CGRect) {
    // Call super constructor
    super.init(frame: frame)
    
    // Assign frame
    self.frame = frame
    
    // Set width to use 100% (relative)
    self.autoresizingMask = [.flexibleWidth]
  }
  
  func setupWaveForm(mic: AKMicrophone) {
    DispatchQueue.main.async {
      // Create the WaveForm
      self.plot = AKNodeOutputPlot(mic, frame: self.frame)
    
      // Set width and height to use 100 % (relative)
      self.plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
      // Set plot properties to generate waveform like plot
      self.plot.plotType = .rolling
      self.plot.shouldFill = true
      self.plot.shouldMirror = true
    
      // Set the color of the line
      self.plot.color = UIColor(red: 245.0 / 255.0, green: 0.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
    
      // Set the background color of the plot
      self.plot.backgroundColor = UIColor.black
    
      // Set the scaling factor of the line
      self.plot.gain = 5
      
      // Cut off lines which go beyond the view bounds
      self.plot.clipsToBounds = true
      
      // Prevent waveform from being rendered all the time
      self.plot.pause()
      
      // Clear the waveform to generate a baseline
      self.plot.clear()
      
      self.timelineBar.updateSize()
      self.timelineBar.autoresizingMask = [.flexibleHeight]
      self.plot.addSubview(self.timelineBar)
    
      // Add the view
      self.addSubview(self.plot)
    }
  }
  
  // Define which node should be used as input node (input signal)
  func setNode(inputNode: AKNode) {
    self.plot.node = inputNode
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class TimelineBar: AKView {
  private let color = UIColor.white
  private var rect = CGRect(x: 50, y: 0, width: 2, height: 70)
  
  convenience init() {
    self.init(frame: CGRect(x: 50, y: 0, width: 2, height: 70))
    // wantsLayer = true
  }
  
  public func updateSize(height: CGFloat = 0) {
    guard let superview = superview else { return }
    let theHeight = height > 0 ? height : superview.frame.height
    rect = CGRect(x: 0, y: 0, width: 2, height: superview.frame.height)
  }
  
  override func draw(_ dirtyRect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    if (context != nil) {
      context?.setShouldAntialias(false)
    }
    color.setFill()
    context?.fill(dirtyRect)
  }
}
