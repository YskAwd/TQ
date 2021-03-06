//
//  TaskBattleViewController.h
//  WWY2
//
//  Created by awaBook on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class WWYViewController;
#import "WWYCommandView.h"
#import "LiveView.h"
#import "WWYTask.h"
#import "WWYHelper_DB.h"
#import "NetworkConnectionManager.h"
#import "StatusManager.h"
#import "AWBuiltInValuesManager.h"
#import "Define.h"

@interface TaskBattleViewController : UIViewController {
	WWYViewController *wWYViewController_;
	WWYCommandView *yesOrNoCommandView_;
	WWYCommandView *taskSuccessOrNotCommandView_;
	LiveView *liveView_;
    UIImageView* monsterView_;
	
	WWYTask *task_;
    
    NetworkConnectionManager* _networkConnectionManager;
    //networkConnectionManager用のkey。データ取得中に閉じるときなどに使う。
	NSString* _networkConnectionKeyForGoogle;
	
	NSString *hero_name_, *enemy_name_, *task_title_;
    NSString *enemy_name_at_battle_, *enemy_name_at_tweet_, *task_title_at_battle_, *task_title_at_tweet_;
    CLLocationCoordinate2D task_coodinate_;
    NSString* task_address_;
    int enemy_image_id_;
}
-(id)initWithFrame:(CGRect)frame withWWYViewController:(WWYViewController*)wWYViewController;
-(void)startBattleOrNotAtTask:(WWYTask*)task;//バトルを始めるかどうかユーザーに聞くstep1
-(void)askBattleYesOrNo;//バトルを始めるかどうかユーザーに聞くstep2（決定させる）
@end
