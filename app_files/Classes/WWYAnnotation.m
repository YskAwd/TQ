//
//  WWYAnnotation.m
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWYAnnotation.h"


@implementation WWYAnnotation
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate;
@synthesize annotationType = annotationType_;
@synthesize userInfo = userInfo_;

-(id) initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude
				 title:(NSString*)title subtitle:(NSString*)subtitle {
	if([super initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude]) {
		if(title == nil) {
			_title = @"";
		}else{
				//これってtitleがdeallocされてもOKなのか？
			//_title = [[NSMutableString alloc]initWithString:title];//NSLog(@"[title retainCount]%d",[title retainCount]);//->1
				//これだけだとたぶん危うい。参照しただけではretainされない。[title retain]が必要。
			//_title = title; //NSLog(@"[title retainCount]%d",[title retainCount]);//->1
				//これでOK。
			//_title = title; [title retain]; //NSLog(@"[title retainCount]%d",[title retainCount]);//->2
				
				//これでいく。copy先がNSMutableStringなら新しくメモり確保される。NSStringならコピー元と同じ箇所をさすだけ。
			_title = [title copy];
		}
		if(subtitle == nil) {
			_subtitle = @"";
		}else {
			_subtitle = [subtitle copy];
		}
		coordinate.latitude=latitude;
		coordinate.longitude=longtitude;
		
		annotationType_ = WWYAnnotationType_normal;
		userInfo_ = nil;
	}
	return self;
}
/*
- (NSString *)title{
	return _title;
}
- (NSString *)subtitle{
	return _subtitle;
}
*/
- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(_title) [_title release];
	if(_subtitle) [_subtitle release];
	userInfo_ = nil;
	[super dealloc];
}
@end
