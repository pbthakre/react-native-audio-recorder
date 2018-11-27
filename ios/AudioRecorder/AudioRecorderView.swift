//
//  AudioRecorderView.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

import Foundation
import UIKit

import AudioKit
import AudioKitUI

// Represents the our native ui (view) component
public class AudioRecorderView: EZAudioPlot {
  // The width of the component received from React Native
  public var componentWidth: Double = 0.00
  
  // The height of the component received from React Native
  public var componentHeight: Double = 0.00
  
  // The background color of the view calculated from the received color
  public var bgColor: UIColor = UIColor(white: 1, alpha: 0.0)
  
  // The color of the line
  public var lineColor: UIColor = UIColor(red: 124.0 / 255.0, green: 219.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
  
  // The plot which represents the waveform
  private var plot : SwiftSiriWaveformView = SwiftSiriWaveformView()
  
  // The timer which calls the waveform update method
  private var timer: Timer?
  
  // Tracker which observes the microphone
  private var microphoneTracker = AKMicrophoneTracker()
  
  // Constructor
  private override init(frame: CGRect) {
    // Call super constructor
    super.init(frame: frame)
    
    // Assign frame
    self.frame = frame
    
    // Set width to use 100% (relative)
    self.autoresizingMask = [.flexibleWidth]
  }

  // Initializes our waveform with defined properties
  func setupWaveform(microphoneTracker: AKMicrophoneTracker) {
    DispatchQueue.main.async {
      // Setup plot
      self.setupWaveformPlot(microphoneTracker: microphoneTracker)
    }
  }
  
  // Update the waveform according to amplitude change
  @objc internal func refreshWaveformWithAmplitude(_:Timer) {
    // Simply set the amplitude to whatever you need and the view will update itself.
    DispatchQueue.main.async {
      // Threshold amplitude so that baseline is less sensitive against noise
      // also augment higher amplitude values so that the baseline is more sensitive against speach
      var amplitude = self.microphoneTracker.amplitude * 5
      if (self.microphoneTracker.amplitude < 0.020) {
        amplitude = 0
      }
      
      self.plot.amplitude = CGFloat(amplitude)
    }
  }
  
  // Propagate view update
  public override func layoutSubviews() {
    self.plot.backgroundColor = self.bgColor
    self.plot.waveColor = self.lineColor
  }
  
  // Setup the plot with custom properties
  private func setupWaveformPlot(microphoneTracker: AKMicrophoneTracker) {
    // Set the tracker
    self.microphoneTracker = microphoneTracker
    
    // Create the plot
    self.plot = SwiftSiriWaveformView()
    
    // Set width and height to use 100 % (relative)
    self.plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // Set the wave line color
    self.plot.waveColor = self.lineColor
    
    // Set amplitude and frequency to zero to create a straight line
    self.plot.amplitude = 0
    self.plot.frequency = 0
    
    // Define the number of secondary lines
    self.plot.numberOfWaves = 1
    
    // Remove secondary lines
    self.plot.secondaryLineWidth = 0
    
    // Set width of primary line
    self.plot.primaryLineWidth = 5

    // Set the background color of the plot
    self.plot.backgroundColor = self.bgColor
    
    // Set the speed of the wave form
    self.plot.phaseShift = 0.5
    
    // Add the view
    self.addSubview(self.plot)
  }
  
  // Resume plot, but keep access level private
  public func resumeWaveform() {
    // Set number of sinus waves
    self.plot.frequency = 4
    
    DispatchQueue.main.async {
      self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.refreshWaveformWithAmplitude(_:)), userInfo: nil, repeats: true)
    }
  }
  
  // Pause plot, but keep access level private
  public func pauseWaveform() {
    DispatchQueue.main.async {
      self.timer?.invalidate()
    }
  }
  
  // Clear plot, but keep access level private
  public func clearWaveform() {
    DispatchQueue.main.async {
      self.plot.amplitude = 0
      self.plot.frequency = 0
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
