//
//  WWYAdController.h
//  WWY
//
//  Created by awaBook on 09/12/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AdMobDelegateProtocol.h"
#import "AdMobView.h"

@interface WWYAdController : NSObject <AdMobDelegate> {
	AdMobView *adMobView_;
	NSObject *delegate_;//このdelegateはAdMobDelegateではなく、AdMobDelegateであるこのクラスのdelegate（管理元）であることに注意。
	NSTimer *refreshAdTimer_;//一定時間ごとに広告をリフレッシュさせるためのタイマー
}

//AdMobDelegateメソッド
- (NSString *)publisherId;
- (BOOL)useTestAd;

//以下はオプションのAdMobDelegateメソッド
- (UIColor *)adBackgroundColor;
//- (NSString *)testAdAction;
//以下、AdMobにユーザーの現在地渡すメソッド。
- (BOOL)mayAskForLocation;
- (CLLocation *)location;
//タイマーを止めるメソッド。破棄前に呼ぶこと。
-(void)stopTimer;


@property (assign) AdMobView *adMobView_;

@end
