//
//  WWYTask.m
//  WWY2
//
//  Created by awaBook on 10/08/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WWYTask.h"


@implementation WWYTask
@synthesize ID = ID_;
@synthesize title = title_;
@synthesize description = description_;
@synthesize enemy = enemy_;
@synthesize enemyImageId = enemyImageId_;
@synthesize coordinate = coordinate_;
@synthesize mission_datetime = mission_datetime_;
@synthesize snoozed_datetime = snoozed_datetime_;
@synthesize done_datetime = done_datetime_;
@synthesize win = win_;

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(title_) [title_ release];
	if(description_) [description_ release];
	if(enemy_) [enemy_ release];
	[super dealloc];
}
- (id)initWithTitle:(NSString*)title description:(NSString*)description enemy:(NSString*)enemy enemyImageId:(int)enemyImageId coordinate:(CLLocationCoordinate2D)coordinate{
	[self initWithID:0 title:title description:description enemy:enemy enemyImageId:enemyImageId coordinate:coordinate];
	return self;
}
- (id)initWithID:(int)ID title:(NSString*)title description:(NSString*)description enemy:(NSString*)enemy enemyImageId:(int)enemyImageId coordinate:(CLLocationCoordinate2D)coordinate{
	if(self = [super init]){
		[title retain],[description retain];[enemy retain];
		ID_ = ID;
		title_ = title;
		description_ = description;
		enemy_ = enemy;
        enemyImageId_ = enemyImageId;
		coordinate_ = coordinate;
        win_ = NO;
	}
	return self;
}

@end
