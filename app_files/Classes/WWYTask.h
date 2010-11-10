//
//  WWYTask.h
//  WWY2
//
//  Created by awaBook on 10/08/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WWYTask : NSObject {
	int ID_;//DBでのid。0ならまだDB登録してないやつ。
	NSString *title_;
	NSString *description_;
	NSString *enemy_;
	CLLocationCoordinate2D coordinate_;
	NSDate *mission_datetime_;//実行日時
	NSDate *snoozed_datetime_;//実行をスキップした日時
	

}
- (id)initWithTitle:(NSString*)title description:(NSString*)description 
			  enemy:(NSString*)enemy coordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithID:(int)ID title:(NSString*)title description:(NSString*)description 
		   enemy:(NSString*)enemy coordinate:(CLLocationCoordinate2D)coordinate;

@property int ID;
@property (retain) NSString *title;
@property (retain) NSString *description;
@property (retain) NSString *enemy;
@property CLLocationCoordinate2D coordinate;
@property (retain) NSDate *mission_datetime;
@property (retain) NSDate *snoozed_datetime;
@end