//
//  AudioRecorderViewController.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 09.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import <reactnativeaudiorecorder-Swift.h>

// Bridges between our AudioRecorderBridge written in Objective-C and our AudioRecorderView Controller written in Swift
@implementation ViewController : UIViewController
  AudioRecorderViewController *myAudioRecorderViewController;

  // Instantiate AudioRecorderViewController
  + (void) initialize {
    myAudioRecorderViewController = [[AudioRecorderViewController alloc] init];
  }

  // Calls the the appropriate method in our Swift class
  - (void) setupRecorder {
    [myAudioRecorderViewController setupRecorder];
  }

  // Calls the the appropriate method in our Swift class
  - (void) triggerRecorderEvent {
    [myAudioRecorderViewController triggerRecorderEvent];
  }

@end
