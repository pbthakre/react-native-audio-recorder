//
//  AudioRecorderManager.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include(“RCTBridge.h”)
#import “RCTBridge.h”
#else
#import “React/RCTBridge.h” // Required when used as a Pod in a Swift project
#endif

#import "AudioRecorderBridge.h"
#import "AudioRecorderViewController.h"

@implementation AudioRecorderBridge
@synthesize bridge = _bridge;

ViewController *myViewController;

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[UIView alloc] init];
}

+ (void) initialize {
  myViewController = [[ViewController alloc] init];
}

RCT_EXPORT_METHOD(setupRecorder)
{
  ViewController* myViewController = [[ViewController alloc] init];
  [myViewController setupRecorder];
}

RCT_EXPORT_METHOD(exampleMethod)
{
  [myViewController mainButtonTouched];
}

@end
