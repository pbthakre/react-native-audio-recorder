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
- (void)viewDidLoad {
  [super viewDidLoad];
  
  AudioRecorderViewController *myView = [[AudioRecorderViewController alloc] init];
  [myView Test];
}

- (void)Test {
  AudioRecorderViewController *myView = [[AudioRecorderViewController alloc] init];
  [myView Test];
}

@end
