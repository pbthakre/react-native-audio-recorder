//
//  AudioRecorderUIView.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 17.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import "AudioRecorderUIView.h"

// Represents the native AudioRecorderUIView
@implementation AudioRecorderUIView
  -(instancetype) init {
    self = [super init];
    if (self) {
      [self setUp];
    }
    return self;
  }

  -(void) setUp {
    UIView * myAudioRecorderUIView = [[UIView alloc] initWithFrame:CGRectMake(-50, -250, 100, 100)];
    [myAudioRecorderUIView setBackgroundColor:[UIColor grayColor]];

    [self addSubview:myAudioRecorderUIView];
  }

@end
