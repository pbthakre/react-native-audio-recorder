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

@interface RCT_EXTERN_MODULE(AudioRecorderController, NSObject)
  RCT_EXTERN_METHOD(setupRecorder: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(startRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(stopRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
@end

// Controls the communication between the Native part and the React part of our application
@implementation AudioRecorderBridge
  AudioRecorderBridge *myAudioRecorderBridge;

  // Instantiate AudioRecorderBridge
  + (void) initialize {
    myAudioRecorderBridge = [AudioRecorderBridge allocWithZone: nil];
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

  // Make this native module available to React
  RCT_EXPORT_MODULE()

  // Make setupRecorder method available to React
  RCT_EXTERN_METHOD(setupRecorder: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

  // Make startRecording method available to React
  RCT_EXTERN_METHOD(startRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

  // Make stopRecording available to React
  RCT_EXTERN_METHOD(stopRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
@end
