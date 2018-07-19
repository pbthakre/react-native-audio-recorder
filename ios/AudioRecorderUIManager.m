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

// Controls the rendering of native view in the React part of our application
@implementation AudioRecorderUIManager
  AudioRecorderUIView *myParentAudioRecorderUIView;
  AudioRecorderUIView *myAudioRecorderUIView;

  // Instantiate AudioRecorderUIView (parent and child)
  + (void) initialize {
    myParentAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    myAudioRecorderUIView = [[AudioRecorderUIView alloc] initWithFrame:CGRectMake(-50, -250, 100, 100)];
    [myParentAudioRecorderUIView addSubview:myAudioRecorderUIView];
  }

  // Change background color of view
  - (void) changeBackgroundColor: (UIColor*)color {
    dispatch_sync(dispatch_get_main_queue(), ^{
      myParentAudioRecorderUIView.subviews.firstObject.backgroundColor = color;
    });
  }

  RCT_EXPORT_MODULE()

  - (UIView *)view {
    return myParentAudioRecorderUIView;
  }

@end
