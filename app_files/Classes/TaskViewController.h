//
//  TaskViewController.h
//  WWY2
//
//  Created by awaBook on 10/07/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WWYViewController;
#import "Define.h"
#import "WWYMapViewController.h"
#import "WWYCommandView.h"
#import "LiveView.h"
#import "WWYTask.h"
#import "DatePickerViewController.h"
#import "WWYHelper_DB.h"
#import "EnemyImagePickerViewController.h"


@interface TaskViewController : UIViewController <UITextViewDelegate>{
	//taskViewModeの型宣言。
	enum WWYTaskViewMode {
		WWYTaskViewMode_ADD,//タスク追加時
        WWYTaskViewMode_ADD_AND_BATTLE_NOW,//たたかうなう!ぼたんによるタスク追加時
		WWYTaskViewMode_EDIT//タスク編集時
	};
	int taskViewMode_;
	
	WWYTask * task_;//編集中のタスク
	
	WWYViewController *wWYViewController_;
	
	LiveView *liveView_;//メッセージを表示するためのLiveView。
	WWYCommandView* fixCommandView_;//決定意思確認のためのコマンドビュー。commandViewIdは1
	WWYCommandView*  yesOrNoCommandView_;//タスクを削除するかどうかを選ばせるコマンドビュー。
    EnemyImagePickerViewController *enemyPickerViewController_;//モンスター画像を選択するためのView。
	DatePickerViewController *datePickerViewController_;//日時を入力するためのView。
    
    BOOL doneTaskEdit_;//過去のタスクを見る画面でこのビューを呼び出しているか
	
	UITextView *taskNameTextView_;
	UIImageView *taskName_waku_;
	UILabel *taskNameLabel_;
	
	UITextView *taskDetailTextView_;
	UIImageView *taskDetail_waku_;
	UILabel *taskDetailLabel_;
	
    UIButton *enemyImgButton_;
    int enemyImgId_;
    
	UITextView *enemyNameTextView_;
	UIImageView *enemyName_waku_;
	UILabel *enemyNameLabel_;
	
	UIButton *dateTimeTextButton_;
	UIImageView *dateTime_waku_;
	UILabel *dateTimeLabel_;
	
	NSDate *mission_dateTime_;//タスクの実行日時
	
	//メモらんだけ動かすのでデフォルトのframeを変数として持つ
	CGRect taskDetailLabelFrame_;
	CGRect taskDetailWakuFrame_;
	CGRect taskDetailTextFrame_;
    
    UIColor* textColorWhenNoFix_;
}
-(id)initWhenAddTaskWithViewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController;//タスク追加時のinitメソッド。
-(id)initWhenEditTask:(WWYTask*)task viewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController;//タスク編集時のinitメソッド。
@property int taskViewMode;
@end
