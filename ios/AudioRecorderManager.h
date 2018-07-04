//  Created by react-native-create-bridge

// import RCTBridgeModule
//#if __has_include(<React/RCTBridgeModule.h>)
//#import <React/RCTBridgeModule.h>
//#elif __has_include(“RCTBridgeModule.h”)
//#import “RCTBridgeModule.h”
//#else
//#import “React/RCTBridgeModule.h” // Required when used as a Pod in a Swift project
//#endif

//@interface AudioRecorder : NSObject <RCTBridgeModule>
//  // Define class properties here with @property
//@end


// MyCustomUIManager.h

//#import <Foundation/Foundation.h>
//#import <React/RCTViewManager.h>
//
//@interface AudioRecorderManager : RCTViewManager
//
//@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>

@interface AudioRecorderManager : RCTViewManager <RCTBridgeModule>
{
  
}

@end
