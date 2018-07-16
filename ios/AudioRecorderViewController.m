//
//  AudioRecorderViewController.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 09.07.18.
//  Copyright © 2018 Facebook. All rights reserved.
//

// This file is the main file for Native UI Controller of Audio Recorder

//#import <Foundation/Foundation.h>

#import "AudioRecorderViewController.h"
#import <reactnativeaudiorecorder-Swift.h>

@implementation ViewController : UIViewController
  AudioRecorderViewController *myAudioRecorderViewController;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (UIView *)view
{
  return [[UIView alloc] init];
}

+ (void) initialize {
  myAudioRecorderViewController = [[AudioRecorderViewController alloc] init];
}

- (void)setupRecorder {
  [myAudioRecorderViewController setupRecorder];
}

- (void)mainButtonTouched {
  [myAudioRecorderViewController mainButtonTouched];
}

@end
