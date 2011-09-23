//
//  AWUserDefaultsManager.m
//  LocationTweet
//
//  Created by AWorkStation on 10/12/17.
//  Copyright 2010 Japan. All rights reserved.
//

#import "AWUserDefaultsManager.h"


@implementation AWUserDefaultsManager

# pragma mark -
# pragma mark 初期化、破棄
- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}
+(id)userDefaultsManager{
	return [[[AWUserDefaultsManager alloc]init]autorelease];
}


# pragma mark -
# pragma mark その他NSUserDefaultsメソッド
- (BOOL)synchronize{
	return [[AWUserDefaultsDriver userDefaultsDriver] synchronize];
}
@end
