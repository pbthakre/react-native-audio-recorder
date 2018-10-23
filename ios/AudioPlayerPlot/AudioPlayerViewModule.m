//
//  AudioPlayerViewModule.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 07.08.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include(“RCTBridgeModule.h”)
#import “RCTBridgeModule.h”
#else
#import “React/RCTBridgeModule.h” // Required when used as a Pod in a Swift project
#endif

#import <React/RCTViewManager.h>

// Represents the bridge which enables access to AudioPlayerView(Manager) in React Native
@interface RCT_EXTERN_MODULE(AudioPlayerViewManager, RCTViewManager)
  // General
  RCT_EXTERN_METHOD(passProperties: (NSString)backgroundColor propLineColor:(NSString)lineColor pixels:(double)pixelsPerSecond);
  RCT_EXTERN_METHOD(setDimensions: (double)width dimHeight:(double)height);

  // Waveform
  RCT_EXTERN_METHOD(renderByFile: (NSString *)fileUrl resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
@end
