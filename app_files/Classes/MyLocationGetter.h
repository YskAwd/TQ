//
//  MyLocationGetter.h
//  RealMapQuest01
//
//  Created by awaBook on 09/01/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class WWYViewController;

@interface MyLocationGetter : NSObject <CLLocationManagerDelegate> { 
	CLLocationManager* locationManager_;
	WWYViewController* delegate_;
	BOOL locationAvailable_;
}
- (void)startUpdates ;
- (void)locationManager:(CLLocationManager*)manager 
	didUpdateToLocation:(CLLocation*)newLocation 
		   fromLocation:(CLLocation*)oldLocation ;
-(void)stopUpdatingLocation;//更新をストップする

@property (assign) WWYViewController* delegate_;
@end
