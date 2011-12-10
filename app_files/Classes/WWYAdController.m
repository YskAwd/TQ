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

-(id)initWithDelegate:(NSObject*)delegate viewController:(UIViewController*)viewController{
	if([super init]){
		//delegate_（AdMobDelegateであるこのクラスのdelegate）設定
		delegate_ = delegate;
		viewController_ = viewController;
		
		//adMobView_を作成。
        CGFloat frameY = viewController.view.frame.origin.y; //0
        CGFloat frameW = viewController.view.frame.size.width; //320
        CGFloat frameH = viewController.view.frame.size.height; //480
        CGFloat toolBarH = 44;
        CGFloat adMobViewH = 48;
		adMobView_ = [AdMobView requestAdWithDelegate:self]; // start a new ad request
		//adMobView_.frame = CGRectMake(0, 368, 320, 48); // set the frame, in this case at the bottom of the screen
        adMobView_.frame = CGRectMake(0, frameH-toolBarH-adMobViewH+frameY, frameW, adMobViewH);
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

#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return @"a14b24920dbaa8f"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	//ここで返すViewControllerに、フルスクリーンのWebView等がモーダルウインドウとして加わる。adViewが表示されているViewControllerでなくてもよい。
	return viewController_;
}

#pragma mark optional notification methods

- (void)didReceiveAd:(AdMobView *)adView{
	NSLog(@"[didReceiveAd!!]");	
}
- (void)didFailToReceiveAd:(AdMobView *)adView{
	NSLog(@"[didFailToReceiveAd!!]");
}/*
- (void)willPresentFullScreenModalFromAd:(AdMobView *)adView{
	NSLog(@"[willPresentFullScreenModalFromAd!!]");
}
- (void)didPresentFullScreenModalFromAd:(AdMobView *)adView{
	NSLog(@"[didPresentFullScreenModalFromAd!!]");
}
- (void)willDismissFullScreenModalFromAd:(AdMobView *)adView{
	NSLog(@"[willDismissFullScreenModalFromAd!!]");
}
- (void)didDismissFullScreenModalFromAd:(AdMobView *)adView{
	NSLog(@"[didDismissFullScreenModalFromAd!!]");
}
- (void)applicationWillTerminateFromAd:(AdMobView *)adView{
	NSLog(@"[applicationWillTerminateFromAd!!]");
}
*/

#pragma mark optional test ad methods

- (NSArray *)testDevices{
	return [NSArray arrayWithObjects:
			ADMOB_SIMULATOR_ID,                             // Simulator
			@"9859ef17ce274324c3856612d57bb5281aa22873",  // Test iPhone 4 4.2
			nil];
}

- (NSString *)testAdActionForAd:(AdMobView *)adView{
	//Acceptable values are @"url", @"app", @"movie", @"call", @"canvas".  For interstitials
	// use "video_int".
	return @"url";
}


#pragma mark optional targeting info methods

- (double)locationLatitude{
	CLLocation *nowLocation = [self getNowLocationForAd];
	return nowLocation.coordinate.latitude;
}
- (double)locationLongitude{
	CLLocation *nowLocation = [self getNowLocationForAd];
	return nowLocation.coordinate.longitude;
}
- (NSDate *)locationTimestamp{
	CLLocation *nowLocation = [self getNowLocationForAd];
	return nowLocation.timestamp;
}

#pragma mark optional appearance control methods

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView{
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}
/*
// Specifies the primary text color for ads.
// Defaults to [UIColor whiteColor].
- (UIColor *)primaryTextColorForAd:(AdMobView *)adView;

// Specifies the secondary text color for ads.
// Defaults to [UIColor whiteColor].
- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView;
*/

#pragma mark awad orinal methods

- (CLLocation *)getNowLocationForAd{
	CLLocation *nowlocation;
	if([delegate_ respondsToSelector:@selector(getNowLocationForAd)]){
		nowlocation = [delegate_ getNowLocationForAd];
	}
	return nowlocation;	
}

-(void)refreshAdLoop:(NSTimer*)timer{
	[adMobView_ requestFreshAd];
}
-(void)stopTimer{
	if(refreshAdTimer_) [refreshAdTimer_ invalidate];refreshAdTimer_ = nil;
}

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(adMobView_) [adMobView_ removeFromSuperview];[adMobView_ autorelease];
	[super dealloc];
}
@end
