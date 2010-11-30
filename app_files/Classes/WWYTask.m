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
@synthesize coordinate = coordinate_;
@synthesize mission_datetime = mission_datetime_;
@synthesize snoozed_datetime = snoozed_datetime_;

- (void)dealloc {
	NSLog(@"WWYTask----------dealloc!!!");
	if(title_) [title_ release];
	if(description_) [description_ release];
	if(enemy_) [enemy_ release];
	[super dealloc];
}
- (id)initWithTitle:(NSString*)title description:(NSString*)description enemy:(NSString*)enemy coordinate:(CLLocationCoordinate2D)coordinate{
	[self initWithID:0 title:title description:description enemy:enemy coordinate:coordinate];
	return self;
}
- (id)initWithID:(int)ID title:(NSString*)title description:(NSString*)description enemy:(NSString*)enemy coordinate:(CLLocationCoordinate2D)coordinate{
	if(self = [super init]){
		[title retain],[description retain];[enemy retain];
		ID_ = ID;
		title_ = title;
		description_ = description;
		enemy_ = enemy;
		coordinate_ = coordinate;
	}
	return self;
}

@end
