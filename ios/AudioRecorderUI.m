// MyCustomUI.m

#import "AudioRecorderUI.h"
#import <MapKit/MapKit.h>

@implementation AudioRecorderUI

-(instancetype)init {
  self = [super init];
  if (self) {
    [self setUp];
  }
  return self;
}

-(void) setUp {
  NSLog(@"Map Setup");
  MKMapView * map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
  [self addSubview:map];
}

@end
