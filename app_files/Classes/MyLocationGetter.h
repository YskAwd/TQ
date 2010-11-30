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
	BOOL headingAvailable_;//コンパス情報が取得できるかどうか
}
- (void)startUpdates ;
- (void)locationManager:(CLLocationManager*)manager 
	didUpdateToLocation:(CLLocation*)newLocation 
		   fromLocation:(CLLocation*)oldLocation ;
-(void)stopUpdatingLocation;//位置情報の更新をストップする
-(void)startUpdatingHeading;//コンパスの更新を開始する
-(void)stopUpdatingHeading;//コンパスの更新をストップする

@property (assign) WWYViewController* delegate_;
@property BOOL headingAvailable_;
@end
