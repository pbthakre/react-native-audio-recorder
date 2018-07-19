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

//  -(void) setUp {
//    UIView * myAudioRecorderUIView = [[UIView alloc] initWithFrame:CGRectMake(-50, -250, 100, 100)];
//    [myAudioRecorderUIView setBackgroundColor:[UIColor grayColor]];
//
//    [self addSubview:myAudioRecorderUIView];
//  }

  - (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"init with frame: %@", NSStringFromCGRect(frame));
    self = [super initWithFrame:frame];
    if ( self ) {
      [self setUp];
    }
    return self;
  }

  - (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"init with coder: %@", aDecoder);
    self = [super initWithCoder:aDecoder];
    if ( self ) {
      [self setUp];
    }
    return self;
  }

  - (void)setUp {
    // self.colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
    self.backgroundColor = [UIColor redColor];
  }

  - (void)layoutSubviews {
    NSLog(@"layout subviews");
  }

@end
