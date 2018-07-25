//
//  SampleView.swift
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Crowdio GmbH. All rights reserved.
//

import UIKit

// Represents the our native ui (view) component
class AudioRecorderView: UIView {
  private override init(frame: CGRect) {
    super.init(frame: frame)
    
    let view = UIView(frame: frame)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.backgroundColor = UIColor.green
    
    self.addSubview(view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
