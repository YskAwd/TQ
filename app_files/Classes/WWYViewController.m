//
//  WWYViewController.m
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WWYViewController.h"
#import "DebugViewController.h"
#import "URLConnectionGetter.h"
#import "MyLocationGetter.h"
#import "ConfigViewController.h"
#import "WWYMapViewController.h"
#import "WWYAnnotation.h"
#import "WWYAdController.h"
#import "TaskViewController.h"
#import "TaskBattleViewController.h"
#import "WWYAdViewController2.h"
#import "WebViewController.h"

@implementation WWYViewController
@synthesize mapViewController_;
@synthesize locationButton_;
@synthesize configButton_;
@synthesize battleNowButton_;
@synthesize searchButton_;
@synthesize otherHerosButton_;
@synthesize networkConnectionManager = networkConnectionManager_;
@synthesize locationButtonMode = locationButtonMode_;

#pragma mark -
#pragma mark 生成・破棄
- (void)dealloc {	
	if(adController_) [adController_ stopTimer];[adController_ autorelease];
	if(mapViewController_) [mapViewController_.view removeFromSuperview];[mapViewController_ release];
	if(configViewController_) [configViewController_.view removeFromSuperview];[configViewController_ release];
	if(toolBar_) [toolBar_ removeFromSuperview];[toolBar_ release];
	if(locationButton_) [locationButton_ release];[configButton_ release];[searchButton_ release];[otherHerosButton_ release]; [battleNowButton_ release];
	if(activityIndicatorView_) [activityIndicatorView_ removeFromSuperview];[activityIndicatorView_ release];
	if(searchBar_) [searchBar_ removeFromSuperview];[searchBar_ release];
	if(myLocationGetter_) [myLocationGetter_ stopUpdatingLocation];[myLocationGetter_ release];
	if(taskBattleManager_) [taskBattleManager_ release];
	if(taskViewController_) [taskViewController_.view removeFromSuperview];[taskViewController_ release];
	if(taskBattleViewController_) [taskBattleViewController_.view removeFromSuperview];[taskBattleViewController_ release];
	if(locationButtonImg_location_) [locationButtonImg_location_ release];
	if(locationButtonImg_heading_) [locationButtonImg_heading_ release];
	if(networkConnectionManager_) [networkConnectionManager_ release];
    if(backCommandView_)[backCommandView_ release];
    [super dealloc];
}

- (void)close {
    [taskCheckTImer_ invalidate];   
}
- (id)init {
    self = [super init];
    if (self) {
		myLocationGetter_ = [[MyLocationGetter alloc]init];
		myLocationGetter_.delegate_ = self;
		//ロケーションの検知を始める
		[myLocationGetter_ startUpdates];
		
		networkConnectionManager_ = [[NetworkConnectionManager alloc]init];
		
		taskBattleManager_ = [[TaskBattleManager alloc]init];
        
        isNowEditingTask_ = NO;
        isNowAttackingTask_ = NO;
        
        //タスクがあるか定期的にチェックするタイマー。MyLocationGetterからlocationが来た時だけでなく、タスクをチェックするため。
        taskCheckTImer_ = [NSTimer scheduledTimerWithTimeInterval:TASK_CHECK_INTERVAL
                                         target:self
                                       selector:@selector(checkTaskAroundNowLocation:)
                                       userInfo:nil
                                        repeats:YES];
	}
    return self;
}

//taskBattleViewController_を生成し、起動する準備。
-(void)makeTaskBattleViewController{
    if(!taskBattleViewController_) [taskBattleViewController_ release];
        taskBattleViewController_ = [[TaskBattleViewController alloc]initWithFrame:CGRectMake(0, 0, 320, 460) withWWYViewController:self];
    configButton_.enabled = false; searchButton_.enabled = false; battleNowButton_.enabled = false,otherHerosButton_.enabled = false;
}
//taskViewController_を生成。
-(void)makeTaskViewController:(int)mode{
    if(!taskViewController_){
        CGRect taskViewFrame = self.view.frame;
        switch (mode) {
            case 0://タスク新規追加の場合
                taskViewController_ = [[TaskViewController alloc]initWhenAddTaskWithViewFrame:taskViewFrame wWYViewController:self];
                break;
            case 1://たたかうなう！ボタンでのタスク新規追加の場合
                taskViewController_ = [[TaskViewController alloc]initWhenAddTaskAndBattleNowWithViewFrame:taskViewFrame wWYViewController:self];
                break;
            default:
                break;
        }
    }
}
# pragma mark -
# pragma mark ViewControlerメソッド************************************************************************

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
//    [super viewDidLoad];
 - (void)loadView {//初期化メソッドをloadViewに変更
	 [super loadView];
// - (void)initView {
	// Custom initialization
	
	//ツールバーとボタンを生成    
    CGFloat frameX = self.view.frame.origin.x; //0
    CGFloat frameY = self.view.frame.origin.y; //20
    CGFloat frameW = self.view.frame.size.width; //320
    CGFloat frameH = self.view.frame.size.height; //460
    CGFloat toolBarH = 44;
    CGRect toolBarFrame = CGRectMake(frameX, frameH-toolBarH, frameW, toolBarH);
	toolBar_ =  [[UIToolbar alloc]initWithFrame:toolBarFrame];
	toolBar_.barStyle = UIBarStyleBlackOpaque;
	locationButtonMode_ = 0;
	locationButtonImg_location_ = [[UIImage imageNamed:@"btn_location.png"]retain];
	locationButtonImg_heading_ = [[UIImage imageNamed:@"btn_heading.png"]retain];
	locationButton_ = [[UIBarButtonItem alloc]initWithImage:locationButtonImg_location_ 
													  style:UIBarButtonItemStyleBordered target:self 
													 action:@selector(doLocationButtonAction)];
	//locationButton_.width = 40;
	locationButton_.enabled = false;
	
	configButton_ = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"command",@"") 
													style:UIBarButtonItemStyleBordered target:self 
												   action:@selector(configModeOnOff)];
    battleNowButton_ = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"battle_now",@"") 
                                                     style:UIBarButtonItemStyleBordered target:self 
                                                    action:@selector(battleNow)];
	
	/*configButton_ = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_config.png"] 
	 style:UIBarButtonItemStyleBordered target:self 
	 action:@selector(configModeOnOff)];
	 configButton_.width = 45;*/
	
	configButton_.enabled = false;
    battleNowButton_.enabled = false;
	
	searchButton_ = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
																 target:self 
																 action:@selector(searchBarShowOnOff)];
	searchButton_.style = UIBarButtonItemStyleBordered;
	searchButton_.width = 40;
	searchButton_.enabled = false;
     
     otherHerosButton_ = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_otherheros.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(openWebSiteOtherHeros)];
     //otherHerosButton_.width = 40;
     otherHerosButton_.enabled = false;
     
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil action:nil]autorelease];
	
	[toolBar_ setItems:[NSArray arrayWithObjects:locationButton_,spacer,configButton_,spacer,battleNowButton_,spacer, /*searchButton_, */ otherHerosButton_, nil]]; //searchButton_を非表示にした
	
	//activityIndicatorViewを生成
	activityIndicatorView_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	//activityIndicatorView_.frame = CGRectMake(16, 429, 20, 20);
    activityIndicatorView_.frame = CGRectMake(16, toolBarFrame.origin.y+15, 20, 20);
	[activityIndicatorView_ startAnimating];
	
	//searcBarを生成
    CGFloat searchBarH = 44;
	searchBar_ = [[UISearchBar alloc]initWithFrame:CGRectMake(frameX, -searchBarH, frameW, searchBarH)];
	searchBar_.showsCancelButton = YES;
	searchBar_.delegate = self;
	
	//mapViewを生成
	//mapViewController_ = [[WWYMapViewController alloc]initWithViewFrame:CGRectMake(frameX, frameY, frameW, 420) parentViewController:self];
    mapViewController_ = [[WWYMapViewController alloc]initWithViewFrame:CGRectMake(frameX, frameY, frameW, frameH-toolBarH) parentViewController:self];
	
	//configViewを生成
	configViewController_ = [[ConfigViewController alloc]initWithViewFrame:CGRectMake(frameX, frameH, frameW, 440) parentViewController:self];
	//locolo codeの宣伝をサーバにとりにいく。
	[configViewController_ getLocoloAd];
	
	//リクルート広告
	//[self showRecruitAd];
	
	//viewに追加
	[self.view addSubview:toolBar_];
	[self.view addSubview:activityIndicatorView_];
	[self.view addSubview:searchBar_];
	[self.view insertSubview:mapViewController_.view atIndex:0];
	[self.view insertSubview:configViewController_.view atIndex:1];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

# pragma mark -
# pragma mark Location関係*******************************************************************
# pragma mark MyLocaitonGetterから新しいCLLocationが来たときに呼ばれる。
-(void)upDatesCLLocation:(CLLocation*)newLocation{
	[mapViewController_ upDatesCLLocation:newLocation];
	[self checkTaskAroundLocation:newLocation];
}
# pragma mark MyLocaitonGetterから新しいCLHeadingが来たときに呼ばれる。
-(void)upDatesCLHeading:(CLHeading*)newHeading{
	[mapViewController_ upDatesCLHeading:newHeading];
}
-(void)stopCLHeading{
	[mapViewController_ stopCLHeading];
}

# pragma mark 設定した秒数待ってロケーションが取得できない場合に、MyLocationGetterから呼ばれる
-(void)locationUnavailable{
	//locationの更新オフは、MyLocationGetterですでにされている
	UIAlertView *locationAlert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NSLocalizedString(@"User Location Unavailable",@"") delegate:nil
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
	[locationAlert show];
	[locationAlert release];
}
# pragma mark -
# pragma mark mapViewController_.mapViewでの座標を変換するメソッド。（mapViewController_.mapView直接だと取得できないので）
-(CGPoint)convertToPointFromLocation:(CLLocation*)location{
	//CGPoint newPoint = [mapView_ convertCoordinate:location.coordinate toPointToView:mapView_];
	//NSLog(@"%f",newPoint.x);
	CGPoint newPoint = [mapViewController_ convertToPointFromLocation:location];
	return newPoint;
}
- (CLLocationCoordinate2D)convertToCoordinateFromPoint:(CGPoint)point{
	//CLLocationCoordinate2D newCoodinate = [mapView_ convertPoint:point toCoordinateFromView:mapView_];
	CLLocationCoordinate2D newCoodinate = [mapViewController_ convertToCoordinateFromPoint:point];
	return newCoodinate;
}

# pragma mark -
# pragma mark ボタンに対応するAction*******************************************************************
//configボタンを押したとき
-(void)configModeOnOff{
	//もしコンパス追随モードなら、それをオフにする。
	if(locationButtonMode_==WWYLocationButtonMode_HEADING) [self doLocationButtonActionAtMode:WWYLocationButtonMode_LOCATION];
	
	if(configButton_.style == UIBarButtonItemStyleBordered){//ボタンのデフォルトのスタイル変えた場合はここも変わるので注意。
		configButton_.style = UIBarButtonItemStyleDone;
		[UIView beginAnimations:@"configViewShow" context:NULL];
		[UIView setAnimationDuration:0.5f];
		configViewController_.view.frame=CGRectMake(configViewController_.view.frame.origin.x, 0, configViewController_.view.frame.size.width, configViewController_.view.frame.size.height);
		[UIView commitAnimations];
		locationButton_.enabled = false;
        battleNowButton_.enabled = false;
		searchButton_.enabled = false;
        otherHerosButton_.enabled = false;
	}else if(configButton_.style == UIBarButtonItemStyleDone){
		configButton_.style = UIBarButtonItemStyleBordered;
		[UIView beginAnimations:@"configViewHide" context:NULL];
		[UIView setAnimationDuration:0.5f];
		//[UIView setAnimationDidStopSelector:@selector(whenconfigViewClosed)];//->なぜかうまくいかん
		configViewController_.view.frame=CGRectMake(configViewController_.view.frame.origin.x, 460, configViewController_.view.frame.size.width, configViewController_.view.frame.size.height);
		[UIView commitAnimations];
		[configViewController_ resetToDefault];
		
		locationButton_.enabled = true;
        battleNowButton_.enabled = true;
		searchButton_.enabled = true;
        otherHerosButton_.enabled = true;
	}
}

//searchボタンを押したとき
-(void)searchBarShowOnOff{
	//もしコンパス追随モードなら、それをオフにする。
	if(locationButtonMode_==WWYLocationButtonMode_HEADING) [self doLocationButtonActionAtMode:WWYLocationButtonMode_LOCATION];
	
	if(searchButton_.style == UIBarButtonItemStyleBordered){
		searchButton_.style = UIBarButtonItemStyleDone;
		[UIView beginAnimations:@"searchBarShow" context:NULL];
		[UIView setAnimationDuration:0.2];
		searchBar_.frame = CGRectMake(0, 0, searchBar_.frame.size.width, searchBar_.frame.size.height);
		[UIView commitAnimations];
		[searchBar_ becomeFirstResponder];
	}else if(searchButton_.style == UIBarButtonItemStyleDone){
		[self hideSearchBar];
	}
}
//searchBarを非表示にする
-(void)hideSearchBar{
	searchButton_.style = UIBarButtonItemStyleBordered;
	[UIView beginAnimations:@"searchBarHide" context:NULL];
	[UIView setAnimationDuration:0.5];
	searchBar_.frame = CGRectMake(0, -44, searchBar_.frame.size.width, searchBar_.frame.size.height);
	[UIView commitAnimations];
}
//たたかうなうボタンを押したとき
-(void)battleNow{
    [self addTaskAndBattleNow];
}
//ohterHerosButtonを押したとき
-(void)openWebSiteOtherHeros{
    [self startUpWebView:WEBSITE_OTHER_HEROES_URL];
}

//locationボタンを押したとき
-(void)doLocationButtonAction{
	[self doLocationButtonActionAtMode:locationButtonMode_+1];
}
# pragma mark 外部からlocationボタンを押したときのアクションを実行させるために呼ばれる
-(void)doLocationButtonActionAtMode:(int)actionMode{
	switch (actionMode) {
		case WWYLocationButtonMode_LOCATION:
			[mapViewController_ setCenterAtCurrentLocation];
			[myLocationGetter_ stopUpdatingHeading];
			[self setLocationButtonMode:WWYLocationButtonMode_LOCATION];
			break;
		case WWYLocationButtonMode_HEADING:
			if(myLocationGetter_.headingAvailable_){//コンパス情報が取得できるなら
				[mapViewController_ setCenterAtCurrentLocation];
				[myLocationGetter_ startUpdatingHeading];
				[self setLocationButtonMode:WWYLocationButtonMode_HEADING];
			}else{
				[myLocationGetter_ stopUpdatingHeading];
				[self setLocationButtonMode:WWYLocationButtonMode_OFF];
			}
			break;
		default:
			[myLocationGetter_ stopUpdatingHeading];
			[self setLocationButtonMode:WWYLocationButtonMode_OFF];
			break;
	}
}
# pragma mark 外部からlocationButtonModeを設定するために呼ばれる。
-(void)setLocationButtonMode:(int)locationButtonMode{
	switch (locationButtonMode) {
		case WWYLocationButtonMode_OFF:
			locationButton_.image = locationButtonImg_location_;
			locationButton_.style = UIBarButtonItemStyleBordered;
			locationButtonMode_ = WWYLocationButtonMode_OFF;
			break;
		case WWYLocationButtonMode_LOCATION:
			locationButton_.image = locationButtonImg_location_;
			locationButton_.style = UIBarButtonItemStyleDone;
			locationButtonMode_ = WWYLocationButtonMode_LOCATION;
			break;
		case WWYLocationButtonMode_HEADING:
			locationButton_.image = locationButtonImg_heading_;
			locationButton_.style = UIBarButtonItemStyleDone;
			locationButtonMode_ = WWYLocationButtonMode_HEADING;
			break;
		default:
			break;
	}
}
# pragma mark -
# pragma mark タスク追加等。ConfigViewControllerから呼ばれる*********************************
-(void)addTask{
	configButton_.enabled = false; battleNowButton_.enabled = false;
    isNowEditingTask_ = YES;
	[self makeTaskViewController:0];
	[mapViewController_ startAddAnotationWithTap];
}
-(void)addTaskAndBattleNow{
    isNowEditingTask_ = YES;
	configButton_.enabled = false; battleNowButton_.enabled = false;
	[self makeTaskViewController:1];
    [taskViewController_ startTaskNameInput];
	[self.view addSubview:taskViewController_.view];
}
-(void)taskBattleAreaDidEndFixing{
	//[mapViewController_ stopAddAnotationWithTap];
	[mapViewController_.mapView_ deselectAnnotation:mapViewController_.nowAddingAnnotation_ animated:NO];
	[taskViewController_ startTaskNameInput];
	[self.view addSubview:taskViewController_.view];
}
//タスク登録処理。成功すればtaskID、失敗すれば0を返す。
-(int)registerTask:(WWYTask*)task{
    int outputTaskID;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
    
    //登録した結果を表示するための一時的なAnnotationの、タイトルとサブタイトル
    //anotationタイトルは、タスクのタイトルがない場合は敵の名前、それもない場合はデフォルト値。
    NSString* annotationTitle = task.title;
    if(!annotationTitle || [annotationTitle isEqualToString:@""]) annotationTitle = task.enemy;
    if(!annotationTitle || [annotationTitle isEqualToString:@""]) annotationTitle = NSLocalizedString(@"task_name_example_at_battle",@"");
    //anotationのサブタイトルは、mission_datetimeとdescriptionを合わせたもの。
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *missionDateStr = [dateFormatter stringFromDate:task.mission_datetime];
    if(!missionDateStr) missionDateStr = @"";
    NSString* annotationSubTitle = [NSString stringWithFormat:@"%@ %@",missionDateStr,task.description];
    if(annotationSubTitle.length > 20) {
        annotationSubTitle = [annotationSubTitle substringToIndex:17];
        annotationSubTitle = [NSString stringWithFormat:@"%@%@",annotationSubTitle,@"..."];
    }else if([annotationSubTitle isEqualToString:@" "]){
        annotationSubTitle = nil;
    }
    
	if(taskViewController_.taskViewMode == WWYTaskViewMode_ADD || taskViewController_.taskViewMode == WWYTaskViewMode_ADD_AND_BATTLE_NOW){//タスク新規追加の場合
//		if(mapViewController_.nowAddingAnnotation_){//これコメントアウトして大丈夫かな？
			mapViewController_.isAddAnotationWithTapMode_ = false;//まずタップで選ぶ機能をOFFに
			outputTaskID = [helperDB insertTask:task];
			if(outputTaskID != 0){
				mapViewController_.nowAddingAnnotation_.title = annotationTitle;
				mapViewController_.nowAddingAnnotation_.subtitle = annotationSubTitle;
				//吹き出しの長さを調節するためにもう一度セレクトする
				[mapViewController_.mapView_ selectAnnotation:mapViewController_.nowAddingAnnotation_ animated:NO];
			}
//		}
	}else if(taskViewController_.taskViewMode == WWYTaskViewMode_EDIT){//既存タスク編集の場合
		BOOL success = [helperDB updateTask:task];
		if(success){
            outputTaskID = task.ID;
			mapViewController_.nowEditingAnnotation_.title = annotationTitle;
			mapViewController_.nowEditingAnnotation_.subtitle = annotationSubTitle;
			//吹き出しの長さを調節するためにもう一度セレクトする
			[mapViewController_.mapView_ selectAnnotation:mapViewController_.nowEditingAnnotation_ animated:NO];
		}
	}
	[helperDB release];
	
	return outputTaskID;
}
//タスク削除
-(BOOL)deleteTask:(int)taskID{
	BOOL success = NO;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	success = [helperDB deleteTask:taskID];
//	if(success)[mapViewController_.mapView_ removeAnnotation:mapViewController_.nowEditingAnnotation_];
    if(success)[helperDB updateTaskAnnotationsFromDB:mapViewController_];
	[helperDB release];
	[taskBattleManager_ updateTasks];
	return success;	
}

//タスク追加フローを途中でキャンセル
-(void)addTaskCanceled:(BOOL)whenDoneTaskEdited{
	[mapViewController_ cancelAddAnotationWithTap];
	[taskViewController_ release]; taskViewController_ = nil;
    if(whenDoneTaskEdited == NO){
    configButton_.enabled = true; battleNowButton_.enabled = true;
    }
    isNowEditingTask_ = NO;
}
//タスク追加フロー全て完了。
-(void)addTaskCompleted{
	[mapViewController_ completeAddAnotationWithTap];
	mapViewController_.nowEditingAnnotation_ = nil;
	[taskViewController_ release]; taskViewController_ = nil;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	[helperDB updateTaskAnnotationsFromDB:mapViewController_];
	[helperDB release];
	[taskBattleManager_ updateTasks];
	configButton_.enabled = true; battleNowButton_.enabled = true;
    isNowEditingTask_ = NO;
}
//タスク追加フロー全て完了してから、すぐにたたかう。
-(void)addTaskCompletedAndBattleNow:(WWYTask*)battleJustNowTask{
    [self addTaskCompleted];
    //たたかいへ
    isNowAttackingTask_ = YES;
    [self makeTaskBattleViewController];
    [taskBattleViewController_ startBattleNow:battleJustNowTask];
    isNowEditingTask_ = NO;
}

//タスク修正開始
-(void)editTaskWithID:(int)taskID{
	if(!taskViewController_){
        isNowEditingTask_ = YES;
		WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
		WWYTask* task = [helperDB getTaskFromDB:taskID];
		taskViewController_ = [[TaskViewController alloc]initWhenEditTask:task viewFrame:CGRectMake(0, 0, 320, 460) wWYViewController:self];
		[self.view addSubview:taskViewController_.view];
		[helperDB release];
	}
}

//タスクが現在地にあるかどうかをチェックする。タイマーによって呼ばれる。
-(void)checkTaskAroundNowLocation:(NSTimer*)timer{
    if(mapViewController_.currentCLLocation_){
        [self checkTaskAroundLocation:mapViewController_.currentCLLocation_];
    }
}

//タスクが近くにあるかどうかをチェックする。タイマーとMyLocationGetterからのトリガーで呼ばれる
-(void)checkTaskAroundLocation:(CLLocation*)location{
	if(!isNowAttackingTask_ && !isNowEditingTask_ && !mapViewController_.isAddAnotationWithTapMode_
	   && configButton_.style == UIBarButtonItemStyleBordered && searchButton_.style == UIBarButtonItemStyleBordered && otherHerosButton_.style == UIBarButtonItemStyleBordered){
        [taskBattleManager_ updateTasks];
		WWYTask *task = [taskBattleManager_ taskAroundLocation:location withInMeter:TASK_HIT_AREA_METER];
		if(task){
            //アプリがバックグラウンドのときの検知なら、LocalNortificationを出す。
            if([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground){
                [taskBattleManager_ snoozeTask:task.ID];//何度もNotificationが出ないようにあらかじめsnoozeしておく
                [self scheduleNotificationWithItem:task];
                //[self startTaskBattle:task];
            }
            //アプリがアクティブなら、バトルフロー開始
            else{
                [self startTaskBattle:task];
            }
			[task release];
		}
	}
}
-(void)startTaskBattle:(WWYTask*)task{
    isNowAttackingTask_ = YES;
    [self makeTaskBattleViewController];
    [taskBattleViewController_ startBattleOrNotAtTask:task];
}
//タスクを回避したとき呼ばれる
-(void)avoidedTaskBattle:(WWYTask*)task{
	[taskBattleManager_ snoozeTask:task.ID];
    [self taskBattleComplete];
}
//タスクに勝って、タスクに完了日時と勝ちを入れる
-(void)doneTheTaskWhenWin:(int)taskID{
    [taskBattleManager_ setDoneDatetimeOnTask:taskID win:YES];
}
//タスクにまけて、タスクに完了日時と負けを入れる
-(void)snoozeTaskWhenLose:(int)taskID{
    [taskBattleManager_ setDoneDatetimeOnTask:taskID win:NO];
}

//タスクバトル終了
-(void)taskBattleComplete{
    //mapViewのannotationをアップデート
    WWYHelper_DB* helper_DB = [[WWYHelper_DB alloc]init];
    [helper_DB updateTaskAnnotationsFromDB:mapViewController_];
    
	[taskBattleViewController_.view removeFromSuperview];[taskBattleViewController_ release];taskBattleViewController_ = nil;
    //過去のタスクを見ているモードじゃなければボタンを戻す
    if(!mapViewController_.taskHistoryPolyline){//ポリラインがあるかどうかで上記を判定
        configButton_.enabled = true; searchButton_.enabled = true; battleNowButton_.enabled = YES; otherHerosButton_.enabled = true;
    }
    isNowAttackingTask_ = NO;
    [helper_DB autorelease];
}

//twitterの認証を始める
-(void)startTwitterAuthentication{
	configButton_.enabled = false; searchButton_.enabled = false; battleNowButton_.enabled = false; otherHerosButton_.enabled = false;
	if(!twitterViewController_) twitterViewController_ = [[TwitterAuthViewController alloc]initWithViewFrame:self.view.frame delegate:self];
	[self.view addSubview:twitterViewController_.view];
	[twitterViewController_ startTwitterOAuth];
}
//twitterの認証が終わったとき、キャンセルされたとき呼ばれる
-(void)twitterAuthenticationEnded{
	[twitterViewController_.view removeFromSuperview];
	[twitterViewController_ release];
	twitterViewController_ = nil;
	configButton_.enabled = true; searchButton_.enabled = true; battleNowButton_.enabled = true; otherHerosButton_.enabled = true;
}
#pragma mark -
#pragma mark historyMap 関連
-(void)startHistoryMap{
    configButton_.enabled = false; battleNowButton_.enabled = false; otherHerosButton_.enabled = false; //searchButton_.enabled = false;
    
    //タスクをdoneのものに入れ替え
    WWYHelper_DB* helper_DB = [[WWYHelper_DB alloc]init];
    [helper_DB removeTaskAnnotationFromMapViewController:mapViewController_];
    [helper_DB getDoneTasksFromDBOnMapViewController:mapViewController_];
    
    //かぶせてセピア調にするビュー
    CGRect historyMapFrame = CGRectMake(0, 0, mapViewController_.view.frame.size.width, mapViewController_.view.frame.size.height);
    sepiaCoverView_ = [[UIView alloc]initWithFrame:historyMapFrame];
    sepiaCoverView_.backgroundColor = [UIColor orangeColor];
    sepiaCoverView_.alpha = 0.3;
    sepiaCoverView_.userInteractionEnabled = NO;
    //[self.view addSubview:sepiaCoverView_];
    [self.view insertSubview:sepiaCoverView_ belowSubview:searchBar_];
    
    //過去のタスクの地図画面のタイトル
    CGRect historyMapTitleLabelFrame = CGRectMake(0, 0, mapViewController_.view.frame.size.width, 40);
    historyMapTitleLabel_ = [[UILabel alloc]initWithFrame:historyMapTitleLabelFrame];
    historyMapTitleLabel_.backgroundColor = [UIColor blackColor];
	historyMapTitleLabel_.textColor = [UIColor whiteColor];
	historyMapTitleLabel_.font = [UIFont systemFontOfSize:18];
	historyMapTitleLabel_.textAlignment = UITextAlignmentCenter;
	historyMapTitleLabel_.text = NSLocalizedString(@"history_of_task", @"");
    //[self.view addSubview:historyMapTitleLabel_];
    [self.view insertSubview:historyMapTitleLabel_ belowSubview:searchBar_];
    
    //キャラクタ達を非表示に
    [mapViewController_ changeHiddenOfCharacter:YES];
    
    //現在に戻るためのコマンドビュー
    CGFloat marginX = -25, marginY = 130; 
    CGRect backCommandFrame = CGRectMake(self.view.frame.size.width*1/5-marginX,self.view.frame.size.height-marginY,
                                 self.view.frame.size.width*3.5/5, 10);
    backCommandView_ = [[WWYCommandView alloc]initWithFrame:backCommandFrame target:self maxColumnAtOnce:1];
    [backCommandView_ insertCommand:NSLocalizedString(@"go_to_present",@"") action:@selector(closeHistoryMap) userInfo:nil AtIndex:0];
    [backCommandView_ columnViewArrowStartBlinking:0];
    [self.view addSubview:backCommandView_];
    
    [helper_DB autorelease];
}
-(void)closeHistoryMap{
    //タスクをundoneのものに入れ替え
    WWYHelper_DB* helper_DB = [[WWYHelper_DB alloc]init];
    [helper_DB removeTaskAnnotationFromMapViewController:mapViewController_];
    [helper_DB getTasksFromDBOnMapViewController:mapViewController_];
    
    //ビューを解放
    [backCommandView_ removeFromSuperview];[backCommandView_ release]; backCommandView_ =nil;
    [historyMapTitleLabel_ removeFromSuperview];[historyMapTitleLabel_ autorelease]; historyMapTitleLabel_ = nil;
    [sepiaCoverView_ removeFromSuperview]; [sepiaCoverView_ autorelease]; sepiaCoverView_ = nil;
    
    //キャラクタ達を表示
    [mapViewController_ changeHiddenOfCharacter:NO];
    
    //polylineを削除
    [mapViewController_.mapView_ removeOverlay:mapViewController_.taskHistoryPolyline];
    //mapViewControllerのプロパティとして保持していたpolylineを解放
    mapViewController_.taskHistoryPolyline = nil;
    
    configButton_.enabled = true; battleNowButton_.enabled = true; searchButton_.enabled = true; otherHerosButton_.enabled = true;
    [helper_DB autorelease];
}
/*
 # pragma mark -
 # pragma mark debugModeメソッド*******************************************************************
-(void)debugModeOnOff{
	if(debugButton_.style == UIBarButtonItemStyleBordered) {
		debugButton_.style = UIBarButtonItemStyleDone;
		[self.view addSubview:debugViewController.view];
	} else {
		debugButton_.style = UIBarButtonItemStyleBordered;
		[debugViewController.view removeFromSuperview];
	}
}
-(void)moveStartOnDebug:(int)direction{
	[mapViewController_ moveStartOnDebug:direction];
}
-(void)moveStopOnDebug{
}
*/
#pragma mark -
#pragma mark Local Notification
- (void)scheduleNotificationWithItem:(WWYTask *)task{

    NSDate *date = [NSDate date];
    NSString* monsterName = task.enemy;
    if([task.enemy isEqualToString:@""] || !task.enemy) monsterName = NSLocalizedString(@"enemy_name_example_at_battle", nil);
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [date addTimeInterval:3];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"ga_arawreta!", nil),monsterName];
    localNotif.alertAction = NSLocalizedString(@"battle_now", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:task.ID] forKey:@"taskID"];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
}
# pragma mark -
# pragma mark 目的地検索のメソッッド。XMLパースなど*******************************************************************
//webに接続しXMLをとりにいくメソッド
-(void)getLatLngXML:(NSString*)searchString{
	word_flg_ = FALSE, lat_flg_ = FALSE, lng_flg_ = FALSE,address_flg_ = FALSE, choice_flg_ = FALSE;
	/*NSString *encode = [[NSString alloc]initWithString:serchString];
	 [encode stringByAddingPercentEscapesUsingEncoding:4];*/
	NSString* encode = (NSString*)CFURLCreateStringByAddingPercentEscapes(  
																		  kCFAllocatorDefault,  
																		  (CFStringRef)searchString,  
																		  NULL,  
																		  NULL,  
																		  kCFStringEncodingUTF8  
																		  );
	[encode autorelease];
//	NSMutableString* urlString = [NSMutableString stringWithString:@"http://www.geocoding.jp/api/?v=1.1&q="];
	NSMutableString* urlString = [NSMutableString stringWithString:@"http://www.locolocode.com/with_the_hero_app/geocoding/?word="];
	[urlString appendString:encode];
	NSLog(@"%@",urlString);
	
	//非同期ネットワーク接続処理。（URLConnectionGetterを使用）
	if(urlConnectionGetter_) {//もしまだネットからジオコード情報取得できてなかったらキャンセルして初期化
		[urlConnectionGetter_ cancel]; [urlConnectionGetter_ release]; urlConnectionGetter_ = nil;
	}
	urlConnectionGetter_ = [[URLConnectionGetter alloc]initWithDelegate:self];
	//このメソッドで実際にURLアクセスし、レスポンスを得る処理が始まる。
	[urlConnectionGetter_ requestURL:urlString];
	
	//以下はNSXMLParserの同期型ネットワーク接続を使った処理。非同期型に変更のためコメントアウト。
	/*if(xmlParser_){
		[xmlParser_ abortParsing], xmlParser_ = nil;
	}
	xmlParser_ = [[NSXMLParser alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
	[xmlParser_ setDelegate:self];
	[xmlParser_ parse];*/
	
}
//URLConnectionGetterから呼ばれるメソッド（レスポンスを取得する）**********************************************
- (void)receivedDataFromNetwork:(NSData*)data URLConnectionGetter:(id)uRLConnectionGetter{
	xmlParser_ = [[NSXMLParser alloc]initWithData:data];
	[xmlParser_ setDelegate:self];
	[xmlParser_ parse];
	//[xmlParser_ autorelease];//autoreleaseするとフリーズ。理由分からず。
}
# pragma mark -
# pragma mark NSXMLParserのdelegateメソッド************************************************************************
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	NSLog(elementName);
	if([elementName isEqualToString:@"word"]){
		word_flg_ = TRUE;
	}else if([elementName isEqualToString:@"lat"]){
		lat_flg_ = TRUE;
	}else if([elementName isEqualToString:@"lng"]){
		lng_flg_ = TRUE;
	}else if([elementName isEqualToString:@"address"]){
		address_flg_ = TRUE;
	/*}else if([elementName isEqualToString:@"choice"]){
		choice_flg_ = YES;*/
	}else if([elementName isEqualToString:@"error"]){
		//NSLog(@"ParserError");
		[parser abortParsing], NSLog(@"abort parsing!");
		UIAlertView *parserErrorAlert = [[UIAlertView alloc] initWithTitle:@"Search Result"
															message:@"Not Found"
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[parserErrorAlert show];
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	NSLog(string);
	if(word_flg_){
		word_flg_ = FALSE;
		annotation_title_ = string;
		[annotation_title_ retain];
	}else if(lat_flg_){
		lat_flg_ = FALSE;
		lat_ = [string floatValue];
		//lat_ = [[[NSNumber alloc]initWithFloat:[string floatValue]]floatValue];
	}else if(lng_flg_){
		lng_flg_ = FALSE;
		lng_ = [string floatValue];
		//lng_ = [[[NSNumber alloc]initWithFloat:[string floatValue]]floatValue];
	}else if(address_flg_){
		address_flg_ = FALSE;
		annotation_subtitle_ = string;
		[annotation_subtitle_ retain];
		//annotationを生成して、mapViewに反映。
		if(lat_!=0 && fabs(lat_)<90.0 && lng_!=0 && fabs(lng_)<180.0){//latとlngがとりうる値ならば
			//現在地を追随しないモードに変更。
			[self doLocationButtonActionAtMode:WWYLocationButtonMode_OFF];
			
			//「地図上をタップして、Anotationを追加するモード」なら、検索結果もタップしたときと同じ動作に
			if(mapViewController_.isAddAnotationWithTapMode_){
				CLLocationCoordinate2D coordinate = {lat_, lng_};
				[mapViewController_ addAnotationWithTapCoordinate:coordinate];
				//subtitleには住所を入れる
				mapViewController_.nowAddingAnnotation_.subtitle = annotation_subtitle_;
				
			}else{//それ以外なら　地図上にannotationとして追加。お城。
				[mapViewController_ addAnnotationWithLat:lat_ Lng:lng_ title:annotation_title_ 
												subtitle:annotation_subtitle_ annotationType:WWYAnnotationType_castle selected:YES moved:YES];
				[mapViewController_ manageAnnotationsAmount];
			}
			//リクルート広告を表示
			[self performSelector:@selector(showRecruitAd) withObject:nil afterDelay:2.0f];

			
		}else{//検索結果がないか、不正なlatlngの場合
			//アラート表示
			UIAlertView *parserErrorAlert = [[UIAlertView alloc] initWithTitle:@"Search Result"
																	   message:@"Not Found"
																	  delegate:self
															 cancelButtonTitle:nil
															 otherButtonTitles:@"OK", nil];
		[parserErrorAlert show];
		}
	/*
	}else if(choice_flg_){
		choice_flg_ = FALSE;
		NSLog(string);
		NSString* newSearchStr = [NSString stringWithString:string];
		[parser abortParsing], NSLog(@"abort parsing!");
		[self getLatLngXML:newSearchStr];
	*/
	}
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
	NSLog(@"parse ended!");
	//パースが終わったら、urlConnectionGetter_を解放。
	if(urlConnectionGetter_) {//タイミングによっては上で既に初期化されてしまってる場合もある(かもしれない)ので、if文で
		[urlConnectionGetter_ cancel]; [urlConnectionGetter_ autorelease]; urlConnectionGetter_ = nil;
	}
}

# pragma mark -
# pragma mark UISearchBarのdelegateメソッド************************************************************************
- (void)searchBarSearchButtonClicked:(UISearchBar *)mySearchBar{
	[mySearchBar resignFirstResponder];//これでキーボードが消える！
	//mySearchBar.showsCancelButton = FALSE;
	if ([self isConnectedNetwork]) {
		//検索Go
		[self getLatLngXML:mySearchBar.text];
	}else{
		//アラート表示
		UIAlertView *networkErrorAlert = [[UIAlertView alloc] initWithTitle:nil
																   message:@"Network Unavailable"
																  delegate:self
														 cancelButtonTitle:nil
														 otherButtonTitles:@"OK", nil];
		[networkErrorAlert show];
		[networkErrorAlert release];
	}
	
	[self hideSearchBar];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)mySearchBar{
	//mySearchBar.showsCancelButton = YES;
	//mySearchBar.showsBookmarkButton = YES;
	//mySearchBar.showsScopeBar = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)mySearchBar{
	[mySearchBar resignFirstResponder];//これでキーボードが消える
	//mySearchBar.showsCancelButton = FALSE;
	
	[self hideSearchBar];
}


# pragma mark -
# pragma mark その他のメソッド************************************************************************

//ネットに繋がってるかどうかを確かめるメソッド
-(BOOL) isConnectedNetwork {
	NSString* theURL = [NSString stringWithFormat:@"http://locolocode.com/hero_map/network_test.html"];
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:theURL]];
	NSURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if(error)
		return NO;
	else
		return YES;
}

-(void)makeAdController{//AdControllerを作る。
	adController_ = [[WWYAdController alloc]initWithDelegate:self viewController:self];
	[configViewController_.view addSubview:adController_.adMobView_];
	//[self.view addSubview:adController_.adMobView_];
}

//UIWebViewを立ち上げる
-(void)startUpWebView:(NSString*)urlString{
	WebViewController* webViewController = [[[WebViewController alloc]initWithUrlString:urlString]autorelease];
	[self presentModalViewController:webViewController animated:YES];
}

//AdMob用に現在地を返すメソッド。WWYAdControllerから呼ばれる
- (CLLocation *)getNowLocationForAd{
	CLLocation *nowLocation;
	if(mapViewController_.mapView_.userLocation){
		//nowLocation = mapViewController_.mapView_.userLocation.location;
		nowLocation = mapViewController_.currentCLLocation_;
	}
	return nowLocation;
}
//activityIndicatorをオンオフする
-(void)activityIndicatorViewOnOff:(bool)ON{
	if(ON) [activityIndicatorView_ startAnimating];
	else [activityIndicatorView_ stopAnimating];
}

//リクルート広告を表示
-(void)showRecruitAd{
	NSArray *languages = [NSLocale preferredLanguages];
	NSString *currentLanguage = [languages objectAtIndex:0];
	if([currentLanguage isEqualToString:@"ja"]){//ユーザの言語環境が日本語なら
		if(!adViewController_){
			adViewController_ = [[WWYAdViewController2 alloc]initWithViewFrame:CGRectMake(0, 380, 320, 36) wWYViewController:self];
			//adViewController_ = [[WWYAdViewController2 alloc]initWithViewFrame:CGRectMake(180, 420, 140, 40) wWYViewController:self];
			
			adViewController_.view.frame = CGRectMake(-adViewController_.view.frame.size.width, adViewController_.view.frame.origin.y, adViewController_.view.frame.size.width, adViewController_.view.frame.size.height);
			[self.view insertSubview:adViewController_.view atIndex:1];
			
			[UIView beginAnimations:nil context:NULL];  
			[UIView setAnimationDuration:0.2];
			adViewController_.view.frame = CGRectMake(0, adViewController_.view.frame.origin.y, adViewController_.view.frame.size.width, adViewController_.view.frame.size.height);
			[UIView commitAnimations];
		}else {
			[adViewController_ refreshAd];
		}
	}
}
//リクルート広告を非表示
-(void)closeRecruiteAdView{
	if(adViewController_){
		[self.view addSubview:adViewController_.view];
		[UIView beginAnimations:nil context:NULL];  
		[UIView setAnimationDuration:0.2];
		adViewController_.view.frame = CGRectMake(-adViewController_.view.frame.size.width, adViewController_.view.frame.origin.y, adViewController_.view.frame.size.width, adViewController_.view.frame.size.height);
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(removeRecruiteAdView)];
		[UIView commitAnimations];
	}
}
//リクルート広告を解放//上のメソッドのアニメーション後に呼び出される
-(void)removeRecruiteAdView{
	if(adViewController_){
		[adViewController_ preCloseAction];
		[adViewController_.view removeFromSuperview];
		[adViewController_ release]; adViewController_ = nil;
	}
}

@end