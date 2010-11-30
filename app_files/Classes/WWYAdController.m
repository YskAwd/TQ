//
//  WWYAdController.m
//  WWY
//
//  Created by awaBook on 09/12/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWYAdController.h"


@implementation WWYAdController
@synthesize adMobView_;

-(id)initWithDelegate:(NSObject*)delegate{
	if([super init]){
		//delegate_（AdMobDelegateであるこのクラスのdelegate）設定
		delegate_ = delegate;

		//adMobView_を作成。
		adMobView_ = [AdMobView requestAdWithDelegate:self]; // start a new ad request
		adMobView_.frame = CGRectMake(0, 388, 320, 48); // set the frame, in this case at the bottom of the screen
		//[self.window addSubview:adMobView_]; // attach the ad to the view hierarchy; self.window is responsible for retaining the ad		
		
		//一定間隔で広告をリフレッシュさせるためのタイマー
		refreshAdTimer_ = [NSTimer scheduledTimerWithTimeInterval:30.5f //30秒いじょうの間隔じゃないと受け付けない。
														  target:self 
														selector:@selector(refreshAdLoop:) 
														userInfo:nil 
														 repeats:YES];
	}
	return self;
}

- (NSString *)publisherId{
	return @"a14b24920dbaa8f";
}

- (BOOL)useTestAd {
	//return YES;//テスト時
	return NO;//リリース時
}

/*
- (NSString *)testAdAction{
	// If implemented, lets you specify the action type of the test ad. Defaults to @"url" (web page).
	// Does nothing if useTestAd is not implemented or returns NO.
	// Acceptable values are @"url", @"app", @"movie", @"itunes", @"call", @"canvas".  For interstitials
	// use "video_int".
	// Normally, the adservers restricts ads appropriately (e.g. no click to call ads for iPod touches).
	// However, for your testing convenience, they will return any type requested for test ads.
	return @"url";
}
*/

- (BOOL)mayAskForLocation{
	return YES;
}

- (CLLocation *)location{
	//NSLog(@"AdMobNeedsLocation!!!!!!!!!!!!!!!");
	CLLocation *nowlocation;
	if([delegate_ respondsToSelector:@selector(getNowLocationForAd)]){
		nowlocation = [delegate_ getNowLocationForAdMob];
	}
	return nowlocation;	
}


- (UIColor *)adBackgroundColor{
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

-(void)refreshAdLoop:(NSTimer*)timer{
	[adMobView_ requestFreshAd];
}
-(void)stopTimer{
	if(refreshAdTimer_) [refreshAdTimer_ invalidate];refreshAdTimer_ = nil;
}

- (void)dealloc {
	NSLog(@"WWYAdController----------dealloc!!!");
	if(adMobView_) [adMobView_ removeFromSuperview];[adMobView_ autorelease];
	[super dealloc];
}
@end
