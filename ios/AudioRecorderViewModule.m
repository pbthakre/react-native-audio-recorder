//
//  AudioRecorderViewModule.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 24.07.18.
//  Copyright © 2018 Crowdio GmbH. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include(“RCTBridgeModule.h”)
#import “RCTBridgeModule.h”
#else
#import “React/RCTBridgeModule.h” // Required when used as a Pod in a Swift project
#endif

#import <React/RCTViewManager.h>

// Represents the bridge which enables access to AudioRecorderView(Manager) in React Native
@interface RCT_EXTERN_MODULE(AudioRecorderViewManager, RCTViewManager)
  RCT_EXTERN_METHOD(setupRecorder: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(startRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(stopRecording: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(startPlaying: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
  RCT_EXTERN_METHOD(stopPlaying: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
@end
