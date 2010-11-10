//
//  CatchTapOnMapView.m
//  WWY2
//
//  Created by awaBook on 10/08/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	MapViewのタップを取得するためのView

#import "CatchTapOnMapView.h"


@implementation CatchTapOnMapView
@synthesize isCatchEnable_;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)delegate {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		delegate_ = delegate;
		
		isCatchEnable_ = false;

    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	//NSLog(@"hitTest() x=%f y=%f", point.x, point.y);
	if(isCatchEnable_ && [delegate_ respondsToSelector:@selector(receiveTapPosition:)]){
		[delegate_ receiveTapPosition:point];
	}
	return [super hitTest:point withEvent:event];
}

- (void)dealloc {
    [super dealloc];
}



@end
