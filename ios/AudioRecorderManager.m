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
AudioRecorderBridge *myAudioRecorderBridge;

+ (id)allocWithZone:(NSZone *)zone {
  static AudioRecorderBridge *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [super allocWithZone:zone];
  });
  return sharedInstance;
}

+ (void) initialize {
  myAudioRecorderBridge = [AudioRecorderBridge allocWithZone: nil];
  myViewController = [[ViewController alloc] init];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"TestEvent"];
}

- (void) audioRecorderEvent
{
  [myAudioRecorderBridge sendNotificationToReactNative];
}

- (void) sendNotificationToReactNative
{
    [self sendEventWithName:@"TestEvent" body:@{@"name": @"Test completed"}];
}


RCT_EXPORT_MODULE()

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
