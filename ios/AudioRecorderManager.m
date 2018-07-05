//
//  AudioRecorderManager.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import "AudioRecorderManager.h"
#import "AudioRecorderUI.h"

@implementation AudioRecorderManager RCT_EXPORT_MODULE()
@synthesize bridge = _bridge;

- (UIView *)view
{
  AudioRecorderUI * myAudioRecorderUI = [[AudioRecorderUI alloc] init];
  return myAudioRecorderUI;
}

@end
