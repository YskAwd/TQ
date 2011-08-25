    //
//  TaskViewController.m
//  WWY2
//
//  Created by awaBook on 10/07/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"
#import "WWYViewController.h"


@implementation TaskViewController
@synthesize taskViewMode = taskViewMode_;

#pragma -
#pragma mark mark 初期化・破棄
- (void)dealloc {
	//autorelease済み。
	//（さらにself.viewのremoveFromSuperview時に子のViewにrelease送られるので、下記もなしで良い。のか？）
	/*if(taskNameLabel_) [taskNameLabel_ removeFromSuperview];
	if(taskName_waku_) [taskNameLabel_ removeFromSuperview];
	if(taskNameTextView_) [taskNameLabel_ removeFromSuperview];
	if(taskDetailLabel_) [taskDetailLabel_ removeFromSuperview];
	if(taskDetail_waku_) [taskDetailLabel_ removeFromSuperview];
	if(taskDetailTextView_) [taskDetailLabel_ removeFromSuperview];*/
	
	if(mission_dateTime_) [mission_dateTime_ release];
	
	if(fixCommandView_) [fixCommandView_ removeFromSuperview];[fixCommandView_ autorelease];
	if(yesOrNoCommandView_)[yesOrNoCommandView_ removeFromSuperview];[yesOrNoCommandView_ autorelease];
	if(liveView_) [liveView_ removeFromSuperview];[liveView_ close];[liveView_ autorelease];
	if(task_) [task_ autorelease];
    [textColorWhenNoFix_ autorelease];
	[wWYViewController_ autorelease];
	NSLog(@"TaskViewController---------------------Dealloc!!");
    [super dealloc];
}
//ベースのinitメソッド。今のところは外部からは呼ばれない。
-(id)initWithViewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController{
	//-(id)initWhenNewTaskWithViewFrame:(CGRect)frame taskCoordinate:(CLLocationCoordinate2D)coordinate WWYViewController:(WWYViewController*)wWYViewController{
	if (self = [super init]) {
		// Custom initialization
		[wWYViewController retain];
		wWYViewController_ = wWYViewController;
		self.view.frame = frame;
		self.view.opaque = false;
		self.view.backgroundColor = [UIColor blackColor];
        textColorWhenNoFix_ = [[UIColor colorWithWhite:0.5 alpha:1.0]retain];
		
		//liveView_を作成（生成のみ）
		if(!liveView_) {
			liveView_ = [[LiveView alloc]initWithFrame:CGRectMake(10, 330, 300, 1) withDelegate:self withMaxColumn:3];
			liveView_.overflowMode = WWYLiveViewOverflowMode_noAction;
			[liveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを最初は表示しないように設定。
		}
	}
	return self;
}
//タスク新規追加時のinitメソッド。
-(id)initWhenAddTaskWithViewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController{
	if (self = [self initWithViewFrame:frame wWYViewController:wWYViewController]) {
		taskViewMode_ = WWYTaskViewMode_ADD;
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:NSLocalizedString(@"select_task_area", @"") withTextID:1];
	}
	return self;
}
//タスク編集時のinitメソッド。
-(id)initWhenEditTask:(WWYTask*)task viewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController{
	if (self = [self initWithViewFrame:frame wWYViewController:wWYViewController]) {
		taskViewMode_ = WWYTaskViewMode_EDIT;
		task_ = task;
		[task_ retain];
		[self initInterface];
				
		//タスクの情報を欄内に入れる。
		//タスク名欄
		taskNameTextView_.text = task_.title;
		
		//たすくのあいて欄
		enemyNameTextView_.text = task_.enemy;
		
		//メモ欄
		taskDetailTextView_.text = task_.description;
		
		//タスク日時欄
		NSString *mission_datetime_txt = [self stringFromDate:task_.mission_datetime];
		if(!mission_datetime_txt) mission_datetime_txt = NSLocalizedString(@"task_dateTime_example", @"");
		[dateTimeTextButton_ setTitle:mission_datetime_txt forState:UIControlStateNormal];
		
		//fixCommandView_を生成、表示
		[self createFixCommandViewForTaskEdit];
		[self.view addSubview:fixCommandView_];
	}
	return self;
}

//入力枠等を生成、表示(各モード共通で使用)
-(void)initInterface{
	//タスク名欄生成
	CGRect taskNameFrame = CGRectMake(15, 10, 290, 85);
	
	CGFloat taskNameFramePadding = 5;
	CGFloat taskNameLabelWidth = 150;
	CGFloat taskNameLabelHeight = 20;
	
	CGRect taskNameLabelFrame = CGRectMake((320-taskNameLabelWidth)/2, taskNameFrame.origin.y,
										   taskNameLabelWidth, taskNameLabelHeight);
	taskNameLabel_ = [[[UILabel alloc]initWithFrame:taskNameLabelFrame]autorelease];
	taskNameLabel_.backgroundColor = [UIColor blackColor];
	taskNameLabel_.textColor = [UIColor whiteColor];
	taskNameLabel_.font = [UIFont systemFontOfSize:16];
	taskNameLabel_.textAlignment = UITextAlignmentCenter;
	taskNameLabel_.text = NSLocalizedString(@"task_name", @"");
	
	CGRect taskNameWakuFrame = CGRectMake(taskNameFrame.origin.x, taskNameFrame.origin.y,
										  taskNameFrame.size.width, taskNameFrame.size.height);
	UIImage *waku = [UIImage imageNamed:@"menu_waku.png"];
	UIImage *stretchable_waku = [waku stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	if (!taskName_waku_) taskName_waku_ = [[[UIImageView alloc]initWithFrame:taskNameWakuFrame]autorelease];
	taskName_waku_.image = stretchable_waku;
	
	CGRect taskNameTextFrame = CGRectMake(taskNameFrame.origin.x+taskNameFramePadding, taskNameFrame.origin.y+taskNameLabelHeight,
										  taskNameFrame.size.width-taskNameFramePadding*2, taskNameFrame.size.height-taskNameLabelHeight);
	if(!taskNameTextView_) taskNameTextView_ = [[[UITextView alloc]initWithFrame:taskNameTextFrame]autorelease];
	taskNameTextView_.backgroundColor = nil;
	taskNameTextView_.textColor = [UIColor whiteColor];
	taskNameTextView_.font = [UIFont systemFontOfSize:16];
	taskNameTextView_.delegate = self;
	taskNameTextView_.returnKeyType = UIReturnKeyDone;
	
	
	//タスクのあいて欄生成
	CGRect enemyNameFrame = CGRectMake(15, 110, 290, 85);
	
	CGFloat enemyNameFramePadding = 5;
	CGFloat enemyNameLabelWidth = 160;
	CGFloat enemyNameLabelHeight = 20;
	
	CGRect enemyNameLabelFrame = CGRectMake(enemyNameFrame.origin.x + (enemyNameFrame.size.width-enemyNameLabelWidth)/2, 
											enemyNameFrame.origin.y, enemyNameLabelWidth, enemyNameLabelHeight);
	enemyNameLabel_ = [[[UILabel alloc]initWithFrame:enemyNameLabelFrame]autorelease];
	enemyNameLabel_.backgroundColor = [UIColor blackColor];
	enemyNameLabel_.textColor = [UIColor whiteColor];
	enemyNameLabel_.font = [UIFont systemFontOfSize:16];
	enemyNameLabel_.textAlignment = UITextAlignmentCenter;
	enemyNameLabel_.text = NSLocalizedString(@"enemy_name", @"");
	
	CGRect enemyNameWakuFrame = enemyNameFrame;
	UIImage *waku_enemyName = [UIImage imageNamed:@"menu_waku.png"];
	UIImage *stretchable_waku_enemyName = [waku_enemyName stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	if (!enemyName_waku_) enemyName_waku_ = [[[UIImageView alloc]initWithFrame:enemyNameWakuFrame]autorelease];
	enemyName_waku_.image = stretchable_waku_enemyName;
	
	CGRect enemyNameTextFrame = CGRectMake(enemyNameFrame.origin.x+enemyNameFramePadding, enemyNameFrame.origin.y+enemyNameLabelHeight,
										   enemyNameFrame.size.width-enemyNameFramePadding*2, enemyNameFrame.size.height-enemyNameLabelHeight);
	if(!enemyNameTextView_) enemyNameTextView_ = [[[UITextView alloc]initWithFrame:enemyNameTextFrame]autorelease];
	enemyNameTextView_.backgroundColor = nil;
	enemyNameTextView_.textColor = [UIColor whiteColor];
	enemyNameTextView_.font = [UIFont systemFontOfSize:16];
	enemyNameTextView_.delegate = self;
	enemyNameTextView_.returnKeyType = UIReturnKeyDone;
	
	//メモ欄生成
	CGRect taskDetailFrame = CGRectMake(15, 210, 290, 125);
	
	CGFloat taskDetailFramePadding = 5;
	CGFloat taskDetailLabelWidth = 50;
	CGFloat taskDetailLabelHeight = 20;
	
	taskDetailLabelFrame_ = CGRectMake((320-taskDetailLabelWidth)/2, taskDetailFrame.origin.y,
											 taskDetailLabelWidth, taskDetailLabelHeight);
	taskDetailLabel_ = [[[UILabel alloc]initWithFrame:taskDetailLabelFrame_]autorelease];
	taskDetailLabel_.backgroundColor = [UIColor blackColor];
	taskDetailLabel_.textColor = [UIColor whiteColor];
	taskDetailLabel_.font = [UIFont systemFontOfSize:16];
	taskDetailLabel_.textAlignment = UITextAlignmentCenter;
	taskDetailLabel_.text = NSLocalizedString(@"task_detail", @"");
	
	taskDetailWakuFrame_ = CGRectMake(taskDetailFrame.origin.x, taskDetailFrame.origin.y,
											taskDetailFrame.size.width, taskDetailFrame.size.height);
	UIImage *waku_detail = [UIImage imageNamed:@"menu_waku.png"];
	UIImage *stretchable_waku_detail = [waku_detail  stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	if (!taskDetail_waku_) taskDetail_waku_ = [[[UIImageView alloc]initWithFrame:taskDetailWakuFrame_]autorelease];
	taskDetail_waku_.image = stretchable_waku_detail;
	taskDetail_waku_.backgroundColor = [UIColor blackColor];
	
	taskDetailTextFrame_ = CGRectMake(taskDetailFrame.origin.x+taskDetailFramePadding, taskDetailFrame.origin.y+taskDetailLabelHeight,
											taskDetailFrame.size.width-taskDetailFramePadding*2, taskDetailFrame.size.height-taskDetailLabelHeight);
	if(!taskDetailTextView_) taskDetailTextView_ = [[[UITextView alloc]initWithFrame:taskDetailTextFrame_]autorelease];
	taskDetailTextView_.backgroundColor = nil;
	//taskDetailTextView_.textColor = textColorWhenNoFix_;
	//taskDetailTextView_.text = NSLocalizedString(@"task_detail_example", @"");
	taskDetailTextView_.textColor = [UIColor whiteColor];
	taskDetailTextView_.font = [UIFont systemFontOfSize:16];
	taskDetailTextView_.delegate = self;
	taskDetailTextView_.returnKeyType = UIReturnKeyDone;
	
	//時間欄生成
	CGRect dateTimeFrame = CGRectMake(15, 350, 140, 80);
	
	CGFloat dateTimeFramePadding = 5;
	CGFloat dateTimeLabelWidth = 100;
	CGFloat dateTimeLabelHeight = 20;
	
	CGRect dateTimeLabelFrame = CGRectMake(dateTimeFrame.origin.x+(dateTimeFrame.size.width-dateTimeLabelWidth)/2, dateTimeFrame.origin.y,
										   dateTimeLabelWidth, dateTimeLabelHeight);
	dateTimeLabel_ = [[[UILabel alloc]initWithFrame:dateTimeLabelFrame]autorelease];
	dateTimeLabel_.backgroundColor = [UIColor blackColor];
	dateTimeLabel_.textColor = [UIColor whiteColor];
	dateTimeLabel_.font = [UIFont systemFontOfSize:16];
	dateTimeLabel_.textAlignment = UITextAlignmentCenter;
	dateTimeLabel_.text = NSLocalizedString(@"task_dateTime", @"");
	
	CGRect dateTimeWakuFrame = CGRectMake(dateTimeFrame.origin.x, dateTimeFrame.origin.y,
										  dateTimeFrame.size.width, dateTimeFrame.size.height);
	UIImage *waku_dateTime = [UIImage imageNamed:@"menu_waku.png"];
	UIImage *stretchable_waku_dateTime = [waku_dateTime  stretchableImageWithLeftCapWidth:5 topCapHeight:5];
	if (!dateTime_waku_) dateTime_waku_ = [[[UIImageView alloc]initWithFrame:dateTimeWakuFrame]autorelease];
	dateTime_waku_.image = stretchable_waku_dateTime;
	
	CGRect dateTimeTextFrame = CGRectMake(dateTimeFrame.origin.x+dateTimeFramePadding, dateTimeFrame.origin.y+dateTimeLabelHeight,
										  dateTimeFrame.size.width-dateTimeFramePadding*2, dateTimeFrame.size.height-dateTimeLabelHeight);
	
	if(!dateTimeTextButton_) dateTimeTextButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
	dateTimeTextButton_.frame = dateTimeTextFrame;
	[dateTimeTextButton_ setTitle:NSLocalizedString(@"task_dateTime_example", @"") forState:UIControlStateNormal];
	//[dateTimeTextButton_ sizeToFit];
	dateTimeTextButton_.center = dateTime_waku_.center;
	[dateTimeTextButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[dateTimeTextButton_ setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
	[dateTimeTextButton_ addTarget:self action:@selector(dateTimeTextTapped) forControlEvents:UIControlEventTouchUpInside];
	
	
	//viewを追加
	[self.view addSubview:taskName_waku_];
	[self.view addSubview:taskNameTextView_];
	[self.view addSubview:taskNameLabel_];
	[self.view addSubview:enemyName_waku_];
	[self.view addSubview:enemyNameTextView_];
	[self.view addSubview:enemyNameLabel_];
	[self.view addSubview:taskDetail_waku_];
	[self.view addSubview:taskDetailTextView_];
	[self.view addSubview:taskDetailLabel_];
	[self.view addSubview:dateTime_waku_];
	[self.view addSubview:dateTimeTextButton_];
	[self.view addSubview:dateTimeLabel_];
}

//タスク名等を入力する画面をスタート
-(void)startTaskNameInput{
	[self initInterface];
	//タスク名欄
	taskNameTextView_.textColor = textColorWhenNoFix_;
	taskNameTextView_.text = NSLocalizedString(@"task_name_example", @"");
	
	//たすくのあいて欄
	enemyNameTextView_.textColor = textColorWhenNoFix_;
	enemyNameTextView_.text = NSLocalizedString(@"enemy_name_example", @"");
	
	//メモ欄
	taskDetailTextView_.textColor = textColorWhenNoFix_;
	taskDetailTextView_.text = NSLocalizedString(@"task_detail_example", @"");
	
	//タスク日時欄
	[dateTimeTextButton_ setTitleColor:textColorWhenNoFix_ forState:UIControlStateNormal];
	[dateTimeTextButton_ setTitle:NSLocalizedString(@"task_dateTime_example", @"") forState:UIControlStateNormal];
	
	//fixCommandView_を一旦破棄
	if(fixCommandView_){
		[fixCommandView_ removeFromSuperview];
		[fixCommandView_ autorelease];
		fixCommandView_ = nil;
	}
	
	//タスク内容決定用のfixCommandView_をもう一度作成
	[self createFixCommandViewForTaskAdd];
	[self.view addSubview:fixCommandView_];
	
	//タスク名を入力させる。
	[taskNameTextView_ becomeFirstResponder];
}

#pragma mark -
#pragma mark 日時指定関係=====================================================================
//日時欄がタップされたら
-(void)dateTimeTextTapped{	
	//日時入力用にDatePickerViewControllerを生成（autorelease済）、モーダルビューで表示
	datePickerViewController_ =
	[[[DatePickerViewController alloc]initWithViewFrame:(CGRect)self.view.frame 
													 target:self 
												   selector:@selector(fixDateTimeEdit)
												   userInfo:nil
										 selectorWhenCancel:@selector(cancelDateTimeEdit)]
	 autorelease];
	[self presentModalViewController:datePickerViewController_ animated:YES];																
}
//日時指定画面で”決定”が押されたら
-(void)fixDateTimeEdit{
	mission_dateTime_ = datePickerViewController_.datePicker.date;
	[mission_dateTime_ retain];
	NSString* dateString = [self stringFromDate:mission_dateTime_];
	[dateTimeTextButton_ setTitle:dateString forState:UIControlStateNormal];
	[dateTimeTextButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[datePickerViewController_ dismissModalViewControllerAnimated:YES];
}
//日時指定画面で”やめる”が押されたら
-(void)cancelDateTimeEdit{
	[datePickerViewController_ dismissModalViewControllerAnimated:YES];
}
//決まった形式でNSDateをNSStringに。
-(NSString*)stringFromDate:(NSDate*)date{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateFormat:@"yy/MM/dd HH:mm"];
	return [dateFormatter stringFromDate:date];
}
//決まった形式でNSStringをNSDateに。
-(NSDate*)dateFromString:(NSString*)string{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateFormat:@"yy/MM/dd HH:mm"];
	return [dateFormatter dateFromString:string];
}

#pragma mark -
#pragma mark textView関係====================================================================
- (void)textViewDidBeginEditing:(UITextView *)textView {
	//メモ欄なら
	if(textView == taskDetailTextView_){
		//キーボードで隠れて見えないので、上に動かす。
		[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
		[UIView setAnimationDuration:0.2];
		
		CGRect newFrame = taskDetailTextView_.frame;
		newFrame.origin.y = 10 + taskDetailLabelFrame_.size.height;
		newFrame.size.height = 200;
		taskDetailTextView_.frame = newFrame;
		
		newFrame = taskDetail_waku_.frame;
		newFrame.origin.y = 10;
		newFrame.size.height = 200;
		taskDetail_waku_.frame = newFrame;
		
		newFrame = taskDetailLabel_.frame;
		newFrame.origin.y = 10;
		taskDetailLabel_.frame = newFrame;
		
		[UIView commitAnimations];
	}
	
    //編集前が例文だったらいったん空にして文字色を変えてから編集に入る。
    //タスク新規追加時のみ
    //if(taskViewMode_ == WWYTaskViewMode_ADD){
        if(textView == taskNameTextView_){
            if([taskNameTextView_.text isEqualToString:NSLocalizedString(@"task_name_example", @"")]){
                taskNameTextView_.text = @"";
                taskNameTextView_.textColor = [UIColor whiteColor];
            }
        }else if(textView == enemyNameTextView_){
            
            if([enemyNameTextView_.text isEqualToString:NSLocalizedString(@"enemy_name_example", @"")]){
                enemyNameTextView_.text = @"";
                enemyNameTextView_.textColor = [UIColor whiteColor];
            }
        }else if(textView == taskDetailTextView_){
            if([taskDetailTextView_.text isEqualToString:NSLocalizedString(@"task_detail_example", @"")]){
                taskDetailTextView_.text = @"";
                taskDetailTextView_.textColor = [UIColor whiteColor];
            }
        }
    //}
}
- (void)textViewDidEndEditing:(UITextView *)textView {
	//メモ欄なら
	if(textView == taskDetailTextView_){
		//位置を元に戻す。
		[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
		[UIView setAnimationDuration:0.2];
		
		taskDetailTextView_.frame = taskDetailTextFrame_;
		taskDetail_waku_.frame = taskDetailWakuFrame_;
		taskDetailLabel_.frame = taskDetailLabelFrame_;
		
		[UIView commitAnimations];
	}
    
    //編集終了時に空だったら文字色を変えて例文に戻す。
    //タスク新規追加時のみ
    if(taskViewMode_ == WWYTaskViewMode_ADD){
        if(textView == taskNameTextView_){
            if(!taskNameTextView_.hasText){
                taskNameTextView_.text = NSLocalizedString(@"task_name_example", @"");
                taskNameTextView_.textColor = textColorWhenNoFix_;
            }else{
                [taskNameTextView_ scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            }
        }else if(textView == enemyNameTextView_){
			if(!enemyNameTextView_.hasText){
				enemyNameTextView_.text = NSLocalizedString(@"enemy_name_example", @"");
				enemyNameTextView_.textColor = textColorWhenNoFix_;
			}else{
				[enemyNameTextView_ scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
			}
		}
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
        return NO;
    }/*else{//一度文字オーバーした後、deleteもキャンセルされてしまうのでそれを直さないとつかえない。
		if (range.location + range.length + [text length] <= TASK_NAME_TEXT_LIMIT_NUM) {
			if ([textView.text length] + [text length] - range.length <= TASK_NAME_TEXT_LIMIT_NUM) {
				return YES;
			}else{
				return NO;
			}
		}
	  }*/return YES;
}
#pragma mark -
#pragma mark 決定するためのCommandView生成
//fixCommandView_を生成する（バトルエリア選択用）
-(void)createFixCommandViewForBattleArea{
	if(!fixCommandView_){
		//fixCommandView_を作る。
		fixCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(200,230,120,1) target:self maxColumnAtOnce:2];
		[fixCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(fixBattleArea) userInfo:nil];
		[fixCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(cancelAddingTask) userInfo:nil];
		//[fixCommandView_ columnViewArrowStartBlinking:0];//arrowボタン点滅
	}else{//すでにあったらデフォルトの状態にリセットする
		[fixCommandView_ resetToDefault]; fixCommandView_.touchEnable = YES;
	}
}
//fixCommandView_を生成する（タスク新規追加時内容決定用）
-(void)createFixCommandViewForTaskAdd{
	if(!fixCommandView_){
		//fixCommandView_を作る。
		fixCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(180,320,120,1) target:self maxColumnAtOnce:2];
		[fixCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(fixAddingTask) userInfo:nil];
		[fixCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(cancelAddingTask) userInfo:nil];
		[fixCommandView_ columnViewArrowStartBlinking:0];//arrowボタン点滅
	}else{//すでにあったらデフォルトの状態にリセットする
		[fixCommandView_ resetToDefault]; fixCommandView_.touchEnable = YES;
	}
}
//fixCommandView_を生成する（タスク修正時内容決定用）
-(void)createFixCommandViewForTaskEdit{
	if(!fixCommandView_){
		//fixCommandView_を作る。
		fixCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(180,300,120,1) target:self maxColumnAtOnce:3];
		[fixCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(fixEditingTask) userInfo:nil];
		[fixCommandView_ addCommand:NSLocalizedString(@"go_back",@"") action:@selector(cancelAddingTask) userInfo:nil];
		[fixCommandView_ addCommand:NSLocalizedString(@"delete",@"") action:@selector(confirmDeleteTask) userInfo:nil];
		[fixCommandView_ columnViewArrowStartBlinking:1];//arrowボタン点滅
	}else{//すでにあったらデフォルトの状態にリセットする
		[fixCommandView_ resetToDefault]; fixCommandView_.touchEnable = YES;
	}
}
//yesOrNoCommandView_を生成する（タスク削除確認用）
-(void)createYesOrNoCommandViewForTaskDelete{
	if(!yesOrNoCommandView_){
		yesOrNoCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(180,320,120,1) target:self maxColumnAtOnce:2];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"yes",@"") action:@selector(deleteTask) userInfo:nil];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"no",@"") action:@selector(cancelDeleteTask) userInfo:nil];
		[yesOrNoCommandView_ columnViewArrowStartBlinking:0];//arrowボタン点滅
	}
}

#pragma mark -
#pragma mark タスク追加/編集/削除。commandViewのタップで呼ばれる
//タスクで戦うエリアが決まったら
-(void)fixBattleArea{
	if(fixCommandView_){
		[fixCommandView_ removeFromSuperview];
		[fixCommandView_ resetToDefault];
	}
	//たたかうばしょが選ばれていたら
	if(wWYViewController_.mapViewController_.nowAddingAnnotation_){
		[self.view removeFromSuperview];
		[wWYViewController_ taskBattleAreaDidEndFixing];
	}else{//たたかうばしょが選ばれてないのでその旨表示
		[liveView_ setTextAndGo:NSLocalizedString(@"battle_area_not_selected",@"") withTextID:2];
	}
}
//タスクを追加するの自体をキャンセルするなら
-(void)cancelAddingTask{
	[self.view removeFromSuperview];
	[wWYViewController_ addTaskCanceled];
}
//タスク追加時、タスクが決まったら
-(void)fixAddingTask{
	//例文のままだったら、空にする。
	if([taskDetailTextView_.text isEqualToString:NSLocalizedString(@"task_detail_example", @"")]){
		taskDetailTextView_.text = @"";
	}
    if([taskNameTextView_.text isEqualToString:NSLocalizedString(@"task_name_example", @"")]){
        taskNameTextView_.text = @"";
    }
    if([enemyNameTextView_.text isEqualToString:NSLocalizedString(@"enemy_name_example", @"")]){
        enemyNameTextView_.text = @"";
    }
    
	/*
	 //テキスト色を白に。（例文そのままの場合でも、それがで登録することを認識させるため。）
	 //と思ったけど、このViewすぐ消えちゃうので、タイマー実装してから。
	 taskNameTextView_.textColor = [UIColor whiteColor];
	 enemyNameTextView_.textColor = [UIColor whiteColor];
	 [dateTimeTextButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	 */

	//taskを生成
	WWYTask *task = [[WWYTask alloc]initWithTitle:taskNameTextView_.text 
									  description:taskDetailTextView_.text 
											enemy:enemyNameTextView_.text 
									   coordinate:wWYViewController_.mapViewController_.nowAddingAnnotation_.coordinate];
	task.mission_datetime = mission_dateTime_;
	
	//taskをdbに登録
	if([wWYViewController_ registerTask:task]){
	   [self.view removeFromSuperview];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_registered",@"") withTextID:3];
	}else{
		[self.view removeFromSuperview];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_not_registered",@"") withTextID:4];
	}
	[task release];
}
//タスク編集時、タスクが決まったら
-(void)fixEditingTask{	
	//taskをdbに登録
	task_.title = taskNameTextView_.text ;
	task_.description = taskDetailTextView_.text;
	task_.enemy = enemyNameTextView_.text;
	task_.mission_datetime = mission_dateTime_;
	
	if([wWYViewController_ registerTask:task_]){
		[self.view removeFromSuperview];
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_registered",@"") withTextID:3];
	}else{
		[self.view removeFromSuperview];
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_not_registered",@"") withTextID:4];
	}
}
//編集中のタスクを削除するか確認する
-(void)confirmDeleteTask{
	[self.view addSubview:liveView_];
	[liveView_ setTextAndGo:NSLocalizedString(@"confirm_task_delete",@"") withTextID:5];
}
//編集中のタスクを削除するなら
-(void)deleteTask{	
	if([wWYViewController_ deleteTask:task_.ID]){
		[self.view removeFromSuperview];
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_deleted",@"") withTextID:3];
	}else{
		[self.view removeFromSuperview];
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:NSLocalizedString(@"task_not_deleted",@"") withTextID:4];
	}
}
//編集中のタスクを削除しないなら
-(void)cancelDeleteTask{
	[liveView_ removeFromSuperview];
	if(yesOrNoCommandView_)[yesOrNoCommandView_ removeFromSuperview];[yesOrNoCommandView_ autorelease];yesOrNoCommandView_ = nil;
	if(fixCommandView_)[fixCommandView_ resetToDefault];fixCommandView_.touchEnable = YES;
}

#pragma mark -
#pragma mark LiveViewDelegateメソッド****************************************************************
//LiveViewのテキスト描画が終わったときに、delegateに通知するメソッド。描画テキストのIDをつけて通知。
//textIDがない場合は、textID=0で送信される。
- (void) liveViewDrawEndedWithID:(int)textID{
	if(textID == 1){
		//fixCommandView_を生成、表示
		[self createFixCommandViewForBattleArea];[wWYViewController_.view addSubview:fixCommandView_];
	}else if(textID == 2){//たたかうばしょが選ばれてない旨表示したあと
		//もう一度たたかう場所を選ぶよう促す。
		[liveView_ setTextAndGo:NSLocalizedString(@"select_task_area", @"") withTextID:1];
	}else if(textID == 3){
		//全てのタスク登録フロー完了。
		NSTimer* timer;
		timer = [NSTimer scheduledTimerWithTimeInterval:2.0
												 target:wWYViewController_
											   selector:@selector(addTaskCompleted)
											   userInfo:nil
												repeats:NO];
	}else if(textID == 4){
		//タスク登録失敗したので登録フロー完了。
		NSTimer* timer;
		timer = [NSTimer scheduledTimerWithTimeInterval:2.0
												 target:wWYViewController_
											   selector:@selector(addTaskCanceled)
											   userInfo:nil
												repeats:NO];
	}else if(textID == 5){//タスクを削除するかどうか確認
		//確認を促すコマンドビューを生成
		[self createYesOrNoCommandViewForTaskDelete];
		[self.view addSubview:yesOrNoCommandView_];
	}
}

@end
