//
//  AudioRecorderUI.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import "AudioRecorderUIManager.h"
#import "reactnativeaudiorecorder-Swift.h"

#import "AudioRecorderUIView.h"
#import <UIKit/UIKit.h>

@import AudioKit;
@import AudioKitUI;
@import UIKit;

// Controls the rendering of native view in the React part of our application
@implementation AudioRecorderUIManager
  AudioRecorderUIView *myAudioRecorderUIView;

  RCT_EXPORT_MODULE()

  - (UIView *) view
  {
    myAudioRecorderUIView = [[AudioRecorderUIView alloc] init];
    return myAudioRecorderUIView;
  }

@end
