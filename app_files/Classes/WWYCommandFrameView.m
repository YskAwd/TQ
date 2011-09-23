//
//  WWYCommandFrameView.m
//  WWY2
//
//  Created by awaBook on 10/08/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WWYCommandFrameView.h"


@implementation WWYCommandFrameView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
 
 //下地になる四角を書く
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetGrayStrokeColor(context, 0, 1);
 CGContextFillRect(context, CGRectMake(3, 3,  self.frame.size.width-6, self.frame.size.height-6));//arrowButtonの上に出っ張ってる分を考慮してy値を指定。	
 
 //枠を書く
 CGContextSetGrayStrokeColor(context, 1, 1);
 CGContextSetLineWidth(context, 3);
 CGContextSetLineJoin(context, kCGLineJoinRound);
  CGContextStrokeRect(context, CGRectMake(3, 3,  self.frame.size.width-6, self.frame.size.height-6));//arrowButtonの上に出っ張ってる分を考慮してy値を指定。
 
}


- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}


@end
