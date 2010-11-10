//
//  WWYCommandArrowView.h
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WWYCommandArrowView : UIView {
	CGFloat arrowSize;
	CGFloat padding;
	NSTimer *baseTimer;
	int blink_i;
}
- (id)initWithFrame:(CGRect)frame withArrowSize:(CGFloat)mySize withPadding:(CGFloat)myPadding ;
-(void)startBlinking;//明滅スタート
-(void)stopBlinking;//明滅ストップ
-(void)close;//クローズ処理
@end
