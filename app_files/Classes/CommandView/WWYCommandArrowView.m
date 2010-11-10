//
//  WWYCommandArrowView.m
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//CommandView2で使うArrowView。マージンの上部分が3に固定。のみ。
#import "WWYCommandArrowView.h"


@implementation WWYCommandArrowView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		arrowSize = 10;
		padding = 3;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame withArrowSize:(CGFloat)mySize withPadding:(CGFloat)myPadding {
	if (self = [super initWithFrame:frame]) {
        // Initialization code
		arrowSize = mySize;
		padding = myPadding;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	UIColor* color_wh = [UIColor whiteColor];
	[color_wh set];
	
	//枠を書く
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(context, 1, 1);
	CGContextSetLineWidth(context, 3);
	//CGContextSetLineJoin(context, kCGLineJoinRound);
	//CGContextStrokeRect(context, CGRectMake(3, 3,  self.frame.size.width-6, self.frame.size.height-6));
	CGContextMoveToPoint(context, padding, 3);
	CGContextAddLineToPoint(context, padding+arrowSize, 3+arrowSize/2);
	CGContextAddLineToPoint(context, padding, 3+arrowSize);
	CGContextFillPath(context);
	
}	
//明滅スタート
-(void)startBlinking{
	if(!baseTimer){
		baseTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f/30.0f
													 target:self
												   selector:@selector(blinking:)
												   userInfo:nil
													repeats:YES];
	}
}
-(void)blinking:(NSTimer*)timer{
	if(blink_i == 1){
		self.alpha = 1.0;
		blink_i = 0;
	}else{
		self.alpha = 0.0;
		blink_i = 1;
	}
}
//明滅ストップ
-(void)stopBlinking{
	if(baseTimer) [baseTimer invalidate]; baseTimer=nil;
	self.alpha = 1.0;
}
-(void)close{
	[self stopBlinking];
}
- (void)dealloc {
	NSLog(@"WWYCommandArrowView---------------------Dealloc!!");
    [super dealloc];
}


@end
