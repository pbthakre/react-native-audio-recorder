//
//  AudioRecorderBridge.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include(“RCTBridge.h”)
#import “RCTBridge.h”
#else
#import “React/RCTBridge.h” // Required when used as a Pod in a Swift project
#endif

#import "AudioRecorderBridge.h"

#import <reactnativeaudiorecorder-Swift.h>

// Controls the communication between the Native part and the React part of our application
@implementation AudioRecorderBridge
  AudioRecorderViewController *myAudioRecorderViewController;
  AudioRecorderBridge *myAudioRecorderBridge;

  // Instantiate ViewController and AudioRecorderBridge
  + (void) initialize {
    myAudioRecorderBridge = [AudioRecorderBridge allocWithZone: nil];
    myAudioRecorderViewController = [[AudioRecorderViewController alloc] init];
  }

  // Creates singleton of AudioRecorderBridge
  + (id) allocWithZone:(NSZone *)zone {
    static AudioRecorderBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
  }

  // Define which event(-names) are supported
  - (NSArray<NSString *> *)supportedEvents {
    return @[@"isRecorderEventSuccessfull", @"lastRecordedFileUrlChangedTo"];
  }

  - (void) isRecorderEventSuccessfull: (BOOL)success {
    [self sendEventWithName:@"isRecorderEventSuccessfull" body:@{@"success": [NSNumber numberWithBool: success]}];
  }

  // Send the file url (location) of the last recorded file to React Native
  - (void) lastRecordedFileUrlChangedTo: (NSString*)fileUrl {
    [self sendEventWithName:@"lastRecordedFileUrlChangedTo" body:@{@"fileUrl": fileUrl}];
  }

  // Make this native module available to React
  RCT_EXPORT_MODULE()

  // Make setupRecorder method available to React
  RCT_EXPORT_METHOD(setupRecorder) {
    [myAudioRecorderViewController setupRecorder];
  }

  // Make startRecording available to React
  RCT_EXPORT_METHOD(startRecording) {
    [myAudioRecorderViewController startRecording];
  }

  // Make stopRecording available to React
  RCT_EXPORT_METHOD(stopRecording) {
    [myAudioRecorderViewController stopRecording];
  }
@end
