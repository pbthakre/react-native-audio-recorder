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
  
  // The background color of the view calculated from the received color
  public var bgColor: UIColor = UIColor(white: 1, alpha: 0.0)
  
  // The color of the line
  public var lineColor: UIColor = UIColor(red: 124.0 / 255.0, green: 219.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
  
  // The number of pixels per second
  public var pixelsPerSecond: Double = 0.0
  
  // The duration of the loaded file in seconds
  private var fileDuration: Double = 0
  
  // The plot which represents the waveform
  private var plot: EZAudioPlot = EZAudioPlot(frame: CGRect.init())
  
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
    
    // Get the screen width
    let screenSize: CGRect = UIScreen.main.bounds
    self.windowWidth = Double(screenSize.width);
  }
  
  // Detect layout changes
  override public func layoutSubviews() {
    // Get the screen width
    let screenSize: CGRect = UIScreen.main.bounds
    self.windowWidth = Double(screenSize.width);
    
    // Calculate the plot width based on the number of pixels and the file duration
    let calcWidth = self.pixelsPerSecond * self.fileDuration
    
    // Set the plot and layer width to the calculated width
    self.plot.frame.size.width = CGFloat(calcWidth)
    self.plot.waveformLayer.frame.size.width = CGFloat(calcWidth)
    
    self.plot.backgroundColor = self.bgColor
    self.backgroundColor = self.bgColor
    self.plot.color = self.lineColor
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
      self.plot.color = self.lineColor
      
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
    // Get the screen width
    let screenSize: CGRect = UIScreen.main.bounds
    self.windowWidth = Double(screenSize.width);
    
    // Check if file is accessible
    do {
      let file: AVAudioFile = try AVAudioFile(forReading: fileUrl)
    } catch {
      // File was not ready
      onError(error)
    }
    
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
        // Clear plot
        self.plot.clearsContextBeforeDrawing = true
        
        // Calculate the plot width based on the number of pixels and the file duration
        let calculatedPlotWidth = self.pixelsPerSecond * self.fileDuration
        
        // Plot starts at the middle of the screen so that the straight line can the take the other half
        self.plot.frame.origin.x = CGFloat(self.windowWidth / 2)
        
        // Set the plot and layer width to the calculated width
        self.plot.frame.size.width = CGFloat(calculatedPlotWidth)
        self.plot.waveformLayer.frame.size.width = CGFloat(calculatedPlotWidth)
      
        // Add the data to the plot
        self.plot.updateBuffer(data?.buffers[0], withBufferSize: (data?.bufferSize)!)
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
