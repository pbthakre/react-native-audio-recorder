//
//  AudioPlayerView.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 07.08.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI

// Represents the native ui (view) component for the player
public class AudioPlayerView: EZAudioPlot {
  // The width of the component received from React Native
  public var componentWidth: Double = 0.00
  
  // The height of the component received from React Native
  public var componentHeight: Double = 0.00

  // The width of the component received from React Native
  public var windowWidth: Double = 0.00

  // The height of the component received from React Native
  public var windowHeight: Double = 0.00
    
  // The duration of the loaded file in seconds
  private var fileDuration: Double = 0
  
  // The plot which represents the waveform
  private var plot: EZAudioPlot = EZAudioPlot(frame: CGRect.init())
    
  // Brand Color
  private var brandColor : UIColor = UIColor(red: 124.0 / 255.0, green: 219.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
  
  // Holds the errors of waveform
  enum WaveFormError: Error {
    case fileNotReady(String)
  }
  
  private override init(frame: CGRect) {
    // Call super constructor
    super.init(frame: frame)
    
    // Assign frame
    self.frame = frame
    
    // Set width to use 100% (relative)
    self.autoresizingMask = [.flexibleWidth]
  }

  // Detect layout changes
  override public func layoutSubviews() {
    // Calculate the number of pixels per second for six seconds
    let pixelPerSecondForSixSeconds = self.windowWidth / 6
    
    // Calculate the plot width based on the number of pixels and the file duration
    let calcWidth = pixelPerSecondForSixSeconds * self.fileDuration

    // Set the plot and layer width to the calculated width
    self.plot.frame.size.width = CGFloat(calcWidth)
    self.plot.waveformLayer.frame.size.width = CGFloat(calcWidth)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Setup the plot with custom properties
  public func setupWaveform() {
    DispatchQueue.main.async {
      // Create view
      self.plot = EZAudioPlot(frame: self.frame)

      // Set width and height to use 100 % (relative)
      self.plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      // Set plot properties to generate waveform like plot
      self.plot.plotType = .buffer
      self.plot.shouldFill = true
      self.plot.shouldMirror = true

      // Set the color of the line
      self.plot.color = self.brandColor

      // Set line width
      self.plot.waveformLayer.lineWidth = 3

      // Cut off lines which go beyond the view bounds
      self.plot.clipsToBounds = true

      // Add the view
      self.addSubview(self.plot)
    }
  }
  
  // Add the data to the plot (waveform)
  public func updateWaveformWithData(fileUrl: URL, onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void)  {
    // Read the file from storage
    let file : EZAudioFile? = EZAudioFile(url: fileUrl)
    
    // Store the duration of the loaded file
    self.fileDuration = Double((file?.duration)!)
    
    // If the file has an id, it is ready to be read
    if (file?.audioFileID != nil) {
      print("Waveform Data")
      
      // Read the waveform data from the audio file
      let data: EZAudioFloatData? = file?.getWaveformData()
      
      // Run ui update on main thread
      DispatchQueue.main.async() {
        // Add the data to the plot
        self.plot.updateBuffer(data?.buffers[0], withBufferSize: (data?.bufferSize)!)
        
        // Calculate the number of pixels per second for six seconds
        let pixelPerSecondForSixSeconds = self.windowWidth / 6
        
        // Calculate the plot width based on the number of pixels and the file duration
        let calculatedPlotWidth = pixelPerSecondForSixSeconds * self.fileDuration
        
        // Create a straight line before the file waveform
        let frontLine = UIView(frame: CGRect(x: 0, y: (self.componentHeight / 2) - 1.5, width: self.windowWidth / 2, height: 3))
        frontLine.backgroundColor = self.brandColor
        self.addSubview(frontLine)
        self.bringSubview(toFront: frontLine)
        
        // Plot starts at the middle of the screen so that the straight line can the take the other half
        self.plot.frame.origin.x = CGFloat(self.windowWidth / 2)
        
        // Set the plot and layer width to the calculated width
        self.plot.frame.size.width = CGFloat(calculatedPlotWidth)
        self.plot.waveformLayer.frame.size.width = CGFloat(calculatedPlotWidth)
        
        // Create a straight line after the file waveform
        let backLine = UIView(frame: CGRect(x: (self.windowWidth / 2) + calculatedPlotWidth, y: (self.componentHeight / 2) - 1.5, width: self.windowWidth / 2, height: 3))
        backLine.backgroundColor = self.brandColor
        self.addSubview(backLine)
        self.bringSubview(toFront: backLine)
      }
      
      // Completed without error
      onSuccess(true)
    } else {
      print("No Waveform Data")
      let error = WaveFormError.fileNotReady("Audio file is not ready!")
      
      // Completed with error
      onError(error)
    }
  }
}