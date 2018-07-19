//
//  AudioRecorderUI.h
//  reactnativeaudiorecorder
//
//  Created by Michael Andorfer on 04.07.18.
//  Copyright © 2018 Crowdio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>

@interface AudioRecorderUIManager : RCTViewManager
  @property (nonatomic) UIView *myParentAudioRecorderUIView;
  @property (nonatomic) UIView *myAudioRecorderUIView;

  - (void) changeBackgroundColor: (UIColor*)color;
@end
