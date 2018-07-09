//
//  AudioRecorderUI.m
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

// This file is the main file for Native UI of Audio Recorder

#import "AudioRecorderUI.h"
#import "reactnativeaudiorecorder-Swift.h"

@import AudioKit;
@import AudioKitUI;
@import UIKit;

@implementation AudioRecorderUI

-(instancetype)init {
  self = [super init];
  if (self) {
    [self setUp];
  }
  return self;
}

-(void) setUp {
  NSLog(@"View Setup");
  //MKMapView * map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
  
  UIView * myview = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 430)];
  [myview setBackgroundColor:[UIColor yellowColor]];
  
  [self addSubview:myview];
}

@end
