//
//  AudioPlayerHelper.m
//  RNNativeAudioRecorder
//
//  Created by Michael Andorfer on 14.08.18.
//  Copyright © 2018 Audvice GmbH. All rights reserved.
//

#import "AudioPlayerHelper.h"

@import AudioKit;

// Implements helper methods for the AudioPlayerPlot
@implementation AudioPlayerHelper : NSObject
    + (void)setShouldExitOnCheckResultFail {
        // Define that EZAudio should throw an error instead of terminating program on error
        EZAudioUtilities.shouldExitOnCheckResultFail = NO;
    }
@end
