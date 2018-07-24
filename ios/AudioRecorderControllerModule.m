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

@interface RCT_EXTERN_MODULE(AudioRecorderController, NSObject)
  RCT_EXTERN_METHOD(setupRecorder: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(startRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(stopRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(startPlaying: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(stopPlaying: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
@end
