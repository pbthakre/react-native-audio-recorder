//
//  AudioRecorderBridge.h
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 08.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include(“RCTBridgeModule.h”)
#import “RCTBridgeModule.h”
#else
#import “React/RCTBridgeModule.h” // Required when used as a Pod in a Swift project
#endif

#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>

// Define which methods and properties have to be implemented in AudioRecorderBridge
@interface AudioRecorderBridge : RCTEventEmitter <RCTBridgeModule>
  - (void) recorderStateChangedTo: (int)state;
  - (void) lastRecordedFileUrlChangedTo: (NSString*)fileUrl;
@end
