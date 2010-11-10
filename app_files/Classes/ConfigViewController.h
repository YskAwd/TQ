//
//  ConfigViewController.h
//  WWY
//
//  Created by awaBook on 09/10/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class WWYViewController;
@class WWYCommandView;
@class WWYCommandColumnView;
@class WWYMapViewController;
@class WWYHelper_DB;
@class MyNSURLConnectionGetter;
@class LiveView;
#import "WWYCommandViewDelegate.h"
#import "LiveViewDelegate.h"

@interface ConfigViewController : UIViewController <WWYCommandViewDelegate, LiveViewDelegate>{
	IBOutlet WWYViewController* wWYViewController_;
	WWYCommandView* configCommandView_;//基本となるcommandView。commandViewIdは0。
	WWYCommandView* mapTypeCommandView_;//MapTypeを選ぶためのcommandView。commandViewIdは1。
	WWYCommandView* magicCommandView_;//じゅもんを選ぶためのcommandView。commandViewIdは2。
	WWYCommandView* annotationCommandView_;//移動先のannotationを選ぶためのcommandView。commandViewIdは3。
	WWYCommandView* party_selectCommandView_;//並び替えの入力のためのコマンドビューcommandViewIdは4
	WWYCommandView* party_resultCommandView_;//並び替えの結果表示のためのコマンドビューcommandViewIdは5
	WWYCommandView* locoloAdContinueCommandView_;//locoloAdLiveView_の表示を次に送るかどうかを選択するためのコマンドビュー。commandViewIdは6
	WWYCommandView* locoloAdYesNoCommandView_;//locolo code広告を見に行くかどうか答えるコマンドビュー。commandViewIdは7
	WWYCommandView* twitterSettingCommandView_;//twitterSettingの種類を選ぶためのcommandView。commandViewIdは8
	
	LiveView *locoloAdLiveView_;//locolo code広告の説明を表示するためのLiveView。
	
	NSMutableArray* partyOrderArray_;//キャラの並び順を格納する。先頭から順にキャラidから作ったNSNumberをいれる。
	
	//URLConnection用変数
	MyNSURLConnectionGetter* urlConnectionGetter_;
	//locolo code広告のための変数
	NSMutableString *locoloAd_name_;
	NSMutableString *locoloAd_description_;
	NSMutableString *locoloAd_url_;
	//perse用変数
	NSXMLParser* xmlParser_;//このrelease処理、再確認必要
	bool locoloAd_nameFlg_;
	bool locoloAd_descriptionFlg_;
	bool locoloAd_urlFlg_;
	bool locoloAd_parseEnded_;
	
}
- (id)initWithViewFrame:(CGRect)frame parentViewController:(WWYViewController*)pViewController;
-(void)changeMapTypeAndHideConfigView:(int)mapType;
-(void)getLocoloAd;//webに接続しlocoloの宣伝をとりにいく
//WWYCommandViewDelegateメソッド
-(void)commandPushedWithCommandString:(NSString*)commandString withColumnNo:(int)columnNo withColumnID:(int)columnId withCommandViewId:(int)commandViewId;
-(void)resetToDefault;//デフォルトの状態にする。外部から呼ぶ。
//LiveViewDelegateメソッド
- (void) liveViewDrawEndedWithID:(int)textID;
- (void) liveViewTextDidOverflow;

@end
