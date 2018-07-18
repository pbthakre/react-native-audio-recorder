//
//  AudioRecorderViewController.h
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 09.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#ifndef AudioRecorderViewController_h
#define AudioRecorderViewController_h

#import <UIKit/UIKit.h>

// Enables access to Swift class AudioRecorderViewController from Objective-C
@class AudioRecorderViewController;

// Define which methods and properties have to be implemented in ViewController of AudioBridge
@interface ViewController : UIViewController
  - (void) setupRecorder;
  - (void) startRecording;
  - (void) stopRecording;
@end

#endif /* AudioRecorderViewController_h */
