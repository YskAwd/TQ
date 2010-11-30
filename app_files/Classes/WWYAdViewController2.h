//
//  WWYAdViewController2.h
//  WWY2
//
//  Created by AWorkStation on 10/11/15.
//  Copyright 2010 Japan. All rights reserved.
//
//リクルート広告のコントローラ
#import <UIKit/UIKit.h>
@class WWYViewController;

@interface WWYAdViewController2 : UIViewController <NSXMLParserDelegate>{
	WWYViewController *_wWYViewController;
	
	NSString *_dokoikuBasicURL;
	
	UILabel *_adTextLabel;
	//UIImageView *_ad_wakuImageView;
	UIImageView *_ad_iconImageView;
	UIButton* _adLinkButton;//ボタンは透明にしておく
	
	//NSTimer *_refreshAdTimer;//一定時間ごとに広告をリフレッシュさせるためのタイマー
	NSTimer *_closeAdTimer;//一定時間後に広告を閉じるためのタイマー
	
	//広告のリンク先url
	NSString* _adURL;
	
	//parse用
	NSXMLParser *_xmlParser;
	BOOL _parseFlag_ad;
	
	//networkConnectionManager用のkey。データ取得中に閉じるときなどに使う。
	NSString* _connectionKey;
	
}
-(id)initWithViewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController;
-(void)getAndShowAd;//広告をとってきて表示する
@end
