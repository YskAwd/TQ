//
//  CursorButtonView.m
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//LiveViewで使ってる、テキスト送り用の三角ボタン。
#import "CursorButtonView.h"


@implementation CursorButtonView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		blink_i = 1;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code//あとで三角にする。
	[[UIColor whiteColor]set];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextMoveToPoint(context, 5, 0);
	CGContextAddLineToPoint(context, 20, 0);
	CGContextAddLineToPoint(context, 12.5, 9);
	CGContextFillPath(context);
	/*CGContextSetGrayStrokeColor(context, 1, 1);
	CGContextSetLineWidth(context, 3);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextMoveToPoint(context, 10, 0);
	CGContextAddLineToPoint(context, 20, 20);
	CGContextAddLineToPoint(context, 0, 20);
	CGContextFillPath(context);
	//CGContextStrokeRect(context, CGRectMake(0, 0, 10, 10));*/
}
//明滅スタート
-(void)startBlinking{
	if(!baseTimer){
		baseTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f/30.0f
												 target:self
											   selector:@selector(blinking:)
											   userInfo:nil
												repeats:YES];
	}
}
-(void)blinking:(NSTimer*)timer{
	//NSLog(@"timer");
	if(blink_i == 1){
		self.alpha = 1.0;
		blink_i = 0;
	}else{
		self.alpha = 0.2;
		blink_i = 1;
	}
}
//明滅ストップ
-(void)stopBlinking{
	if(baseTimer) [baseTimer invalidate]; baseTimer=nil;
}
-(void)close{
	[self stopBlinking];
}
- (void)dealloc {
	NSLog(@"CursorButtonView---------------------Dealloc!!");
    [super dealloc];
}


@end
