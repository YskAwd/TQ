//
//  CursorButtonView.h
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CursorButtonView : UIView {
	NSTimer *baseTimer;
	int blink_i;
}
-(void)startBlinking;//明滅スタート
-(void)stopBlinking;//明滅ストップ
-(void)close;//クローズ処理

@end
