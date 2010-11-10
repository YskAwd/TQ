//
//  WWYViewController.h
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Define.h"
@class DebugViewController;
@class MyNSURLConnectionGetter;
@class MyLocationGetter;
@class ConfigViewController;
@class WWYMapViewController;
@class WWYAdController;
@class TaskViewController;
@class TaskBattleViewController;
#import "WWYHelper_DB.h"
#import "WWYTask.h"
#import "TaskBattleManager.h"
#import "TwitterManager.h"
#import "TwitterAuthViewController.h"



@interface WWYViewController : UIViewController <MKMapViewDelegate,UISearchBarDelegate> {
	
	WWYMapViewController* mapViewController_;
	ConfigViewController* configViewController_;
	
	MyLocationGetter* myLocationGetter_;
	TaskBattleManager* taskBattleManager_;
	TaskViewController *taskViewController_;
	TaskBattleViewController *taskBattleViewController_;
	
	TwitterAuthViewController *twitterViewController_;
	
	UIToolbar *toolBar_;
	UIBarButtonItem* locationButton_;
	UIBarButtonItem* configButton_;
	UIBarButtonItem* searchButton_;
	UISearchBar* searchBar_;
	UIActivityIndicatorView *activityIndicatorView_;//現在地をキャッチするまでのインジケータ
	
	WWYAdController *adController_;
	
	MyNSURLConnectionGetter* urlConnectionGetter_;
	
	//以下デバッグ用。debugViewControllerを生成して、viewを表示するコードは書いてない（以前はxibで配置していたので）
	//DebugViewController* debugViewController_;
	//IBOutlet UIBarButtonItem* debugButton_;
	
	//perse用変数
	NSXMLParser* xmlParser_;
	Boolean lat_flg_;
	Boolean lng_flg_;
	Boolean choice_flg_;
	Boolean word_flg_;
	Boolean address_flg_;
	CGFloat lat_;
	CGFloat lng_;
	NSString* annotation_title_;
	NSString* annotation_subtitle_;
}
-(void)upDatesCLLocation:(CLLocation*)newLocation;//MyLocaitonGetterから新しいCLLocationが来たときに呼ばれる。
-(void)setCenterAtCurrentLocation;
-(void)configModeOnOff;
-(void)searchBarShowOnOff;
-(void)hideSearchBar;
//-(IBAction)debugModeOnOff;
-(void)moveStartOnDebug:(int)direction;
-(void)moveStopOnDebug;
-(void)activityIndicatorViewOnOff:(bool)ON;
-(CGPoint)convertToPointFromLocation:(CLLocation*)location;//characterViewから、自分の位置を計算するために呼ばれる
-(CLLocationCoordinate2D)convertToCoordinateFromPoint:(CGPoint)point;//他クラスから位置を計算するために呼ばれる（未使用?）

-(void)addTask;
-(void)openAddQuestView;
-(void)taskBattleAreaDidEndFixing;//タスクのバトルエリア決定
-(BOOL)registerTask:(WWYTask*)task;//タスク登録処理
-(void)addTaskCanceled;//タスク追加フローを途中でキャンセル
-(void)addTaskCompleted;//タスク追加フロー全て完了
-(void)checkTaskAroundLocation:(CLLocation*)location;//タスクが近くにあるかどうかをチェックする
-(void)avoidedTaskBattle:(WWYTask*)task;//タスクを回避したとき呼ばれる
-(void)tweetOfWin:(BOOL)winOrNot;//勝ったか負けたかをツイートする。
-(void)taskBattleComplete;//タスクバトル終了


@property (readonly,assign) WWYMapViewController* mapViewController_;
@property (readonly,assign) UIBarButtonItem* locationButton_;
@property (readonly,assign) UIBarButtonItem* searchButton_;
@property (readonly,assign) UIBarButtonItem* configButton_;



@end

