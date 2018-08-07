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
  
  // The plot which represents the waveform
  private var plot : AKTableView = AKTableView(AKTable.init(), frame: CGRect.init())
  
  private override init(frame: CGRect) {
    // Call super constructor
    super.init(frame: frame)
    
    // Assign frame
    self.frame = frame
    
    // Set width to use 100% (relative)
    self.autoresizingMask = [.flexibleWidth]
  }
  
  // Setup the plot with custom properties
  func setupWaveform(fileUrl: URL, onSuccess: @escaping (Bool) -> Void, onError: @escaping (Error) -> Void) {
    do {
      let url = fileUrl
      
      // Read the file from storage
      let file = try AKAudioFile.init(forReading: fileUrl)
      
      // Create the waveform from file
      let table = AKTable(file: file)
      
      // Create view
      DispatchQueue.main.async {
        self.plot = AKTableView(table, frame: CGRect(x: 0, y: 0, width: self.componentWidth, height: self.componentHeight))
      
        // Set width and height to use 100 % (relative)
        self.plot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
        // Add the view
        self.addSubview(self.plot)
      }
      
      // Completed without error
      onSuccess(true)
    } catch {
      // Aborted with error
      onError(error)
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
