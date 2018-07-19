//
//  AudioRecorderUI.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import "AudioRecorderUIManager.h"
#import "reactnativeaudiorecorder-Swift.h"

#import "AudioRecorderUIManager.h"
#import "AudioRecorderUIView.h"
#import <UIKit/UIKit.h>

@import AudioKit;
@import AudioKitUI;
// @import UIKit;

//@interface AudioRecorderUIManager()
//
//  // - (void) changeBackgroundColor: (UIColor*)color;
//@end

// Controls the rendering of native view in the React part of our application
@implementation AudioRecorderUIManager
  AudioRecorderUIManager *myAudioRecorderUIManager;
  AudioRecorderUIView *myParentAudioRecorderUIView;
  AudioRecorderUIView *myAudioRecorderUIView;

  // Instantiate AudioRecorderUIManager and AudioRecorderUIView
  + (void) initialize {
    //myAudioRecorderUIManager = [AudioRecorderUIManager allocWithZone: nil];
    //myAudioRecorderUIView = [[AudioRecorderUIView alloc] init];
    
    myParentAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    myAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [myParentAudioRecorderUIView addSubview:myAudioRecorderUIView];
  }

  // Creates singleton of AudioRecorderUIManager
  + (id) allocWithZone:(NSZone *)zone {
    static AudioRecorderUIManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
  }

  // Instantiate ViewController and AudioRecorderBridge
  - (void) changeBackgroundColor: (UIColor*)color {
    dispatch_sync(dispatch_get_main_queue(), ^{
      myParentAudioRecorderUIView.subviews.firstObject.backgroundColor = color;
    });
  }

  RCT_EXPORT_MODULE()

//  - (instancetype)init {
//    self = [super init];
//    if ( self ) {
//      NSLog(@"color picker manager init");
//      myParentAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//      myAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//
//      [myParentAudioRecorderUIView addSubview:myAudioRecorderUIView];
//    }
//    return self;
//  }

  - (UIView *)view {
    NSLog(@"color picker manager -view method");
    return myParentAudioRecorderUIView;
  }

//  - (UIView *) view
//  {
//    return myAudioRecorderUIView;
//  }

@end
