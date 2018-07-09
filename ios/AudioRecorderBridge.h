//
//  AudioRecorderBridge.h
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 08.07.18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include(“RCTBridgeModule.h”)
#import “RCTBridgeModule.h”
#else
#import “React/RCTBridgeModule.h” // Required when used as a Pod in a Swift project
#endif

@interface AudioRecorderBridge : NSObject <RCTBridgeModule>
  // Define class properties here with @property
@end
