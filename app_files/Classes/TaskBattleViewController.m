    //
//  TaskBattleViewController.m
//  WWY2
//
//  Created by awaBook on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskBattleViewController.h"
#import "WWYViewController.h"

@implementation TaskBattleViewController


- (void)dealloc {
	if(wWYViewController_) [wWYViewController_ autorelease];
	if(yesOrNoCommandView_) [yesOrNoCommandView_ removeFromSuperview];[yesOrNoCommandView_ autorelease];
	if(liveView_) [liveView_ removeFromSuperview];[liveView_ autorelease];
    if(monsterView_) [monsterView_ removeFromSuperview];[monsterView_ autorelease];
	if(task_) [task_ release];
	if(hero_name_) [hero_name_ release];
	NSLog(@"TaskBattleViewController---------------------Dealloc!!");
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame withWWYViewController:(WWYViewController*)wWYViewController{
	if (self = [super init]) {
		[wWYViewController retain];
		wWYViewController_ = wWYViewController;
		self.view.frame = frame;
		self.view.opaque = false;
		self.view.backgroundColor = [UIColor blackColor];
		
		//liveView_を作成
		if(!liveView_) {
			liveView_ = [[LiveView alloc]initWithFrame:CGRectMake(10, 330, 300, 1) withDelegate:self withMaxColumn:3];
			liveView_.overflowMode = WWYLiveViewOverflowMode_noAction;
			[liveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを最初は表示しないように設定。
		}
        
        //monsterViewを生成
        if(!monsterView_) {
            monsterView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monster.png"]];
            monsterView_.center = CGPointMake(self.view.center.x, self.view.frame.size.height*0.3);
        }
    }
    return self;
}
//バトルを始めるかどうかユーザーに聞くstep1。このクラスの起点のメソッド。
-(void)startBattleOrNotAtTask:(WWYTask*)task{
	[task retain];
	task_ = task;

	//ヒーロー名(twitter username)//ヒーロー名のみdealoc時にリリース。    
    hero_name_ = [[[NSUserDefaults standardUserDefaults]objectForKey:@"twitter_username"]retain];
    if(!hero_name_) hero_name_ = @"";
	
	//モンスター名
	enemy_name_ = task_.enemy;
    //if([task_.enemy isEqualToString:@""]) enemy_name_ = NSLocalizedString(@"enemy_name_example_at_battle", @"");
    if(!enemy_name_) enemy_name_ = @"";
    enemy_name_at_battle_ = enemy_name_at_tweet_ = enemy_name_;
    if([enemy_name_ isEqualToString:@""]) {
        enemy_name_at_battle_ = NSLocalizedString(@"enemy_name_example_at_battle", @"");
        enemy_name_at_tweet_ = NSLocalizedString(@"enemy_name_example_at_tweet", @"");
    }
	
	//タスク名
	task_title_ = task_.title;
	//if([task_.title isEqualToString:@""]) task_title_ = NSLocalizedString(@"task_name_example", @"");
    if(!task_title_) task_title_ = @"";
    task_title_at_battle_ = task_title_at_tweet_ = task_title_;
    if([task_title_at_battle_ isEqualToString:@""]) {
        task_title_at_battle_ = NSLocalizedString(@"task_name_example_at_battle", @"");
        task_title_at_tweet_ = NSLocalizedString(@"task_name_example_at_tweet", @"");
    }
    
    //タスクの位置
    task_coodinate_ = CLLocationCoordinate2DMake(task_.coordinate.latitude, task_.coordinate.longitude);
    
	if(liveView_){
		[wWYViewController_.view addSubview:liveView_];
		[liveView_ setTextAndGo:[NSString stringWithFormat:NSLocalizedString(@"encounter_task", @""),enemy_name_at_battle_,enemy_name_at_battle_] 
		   actionAtTextFinished:@selector(askBattleYesOrNo) userInfo:nil target:(id)self];
	}
}
//バトルを始めるかどうかユーザーに聞くstep2（決定させる）
-(void)askBattleYesOrNo{
	if(!yesOrNoCommandView_){
		yesOrNoCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-70, self.view.frame.size.height/2-50, 140, 1) 
								   target:self maxColumnAtOnce:2];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"yes",@"") action:@selector(startBattle) userInfo:nil];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"no",@"") action:@selector(avoidBattle) userInfo:nil];
		[wWYViewController_.view addSubview:yesOrNoCommandView_];
	}
}
-(void)startBattle{
	[yesOrNoCommandView_ removeFromSuperview];
	[liveView_ removeFromSuperview];
	if(task_){
        [self.view addSubview:monsterView_];
		[self.view addSubview:liveView_];
		[wWYViewController_.view addSubview:self.view];
		
		NSMutableString *arawareta_txt = 
		[NSMutableString stringWithFormat:@"%@\n%@",
		 [NSString stringWithFormat:NSLocalizedString(@"ga_arawreta!",@""),enemy_name_at_battle_],
		 [NSString stringWithFormat:NSLocalizedString(@"no_kougeki!",@""),NSLocalizedString(@"hero", @"")]
		 ];
		
		[liveView_ setTextAndGo:arawareta_txt actionAtTextFinished:@selector(chooseSuccessOrNot) userInfo:nil target:self];
	}
}
-(void)avoidBattle{
	
	liveView_.actionDelay = 1.0;
	[liveView_ setTextAndGo:[NSString stringWithFormat:NSLocalizedString(@"avoided_battle", @""),enemy_name_at_battle_] 
	   actionAtTextFinished:@selector(avoidedTaskBattle:) userInfo:task_ target:wWYViewController_];
}

//タスクが成功したかどうかを選ばせる。
-(void)chooseSuccessOrNot{
//taskSuccessOrNotCommandView_を生成、表示。
	if(!taskSuccessOrNotCommandView_) {
		taskSuccessOrNotCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(100,200,200,1) target:self maxColumnAtOnce:3];
		[taskSuccessOrNotCommandView_ addCommand:NSLocalizedString(@"task_complete", @"") action:@selector(win) userInfo:nil];
		[taskSuccessOrNotCommandView_ addCommand:NSLocalizedString(@"task_fail", @"") action:@selector(lose) userInfo:nil];
		[taskSuccessOrNotCommandView_ addCommand:NSLocalizedString(@"escape", @"") action:@selector(escape) userInfo:nil];
	}
	[self.view addSubview:taskSuccessOrNotCommandView_];
}

-(void)win{
	[taskSuccessOrNotCommandView_ removeFromSuperview];
	
	[wWYViewController_ removeTask:task_.ID];
		
	NSMutableString *taoshita_txt = 
	[NSMutableString stringWithFormat:NSLocalizedString(@"wo_taoshita!",@""),enemy_name_at_battle_];
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:taoshita_txt actionAtTextFinished:@selector(tweetOfWinOrLose:) userInfo:(id)kCFBooleanTrue target:self];
}
-(void)lose{
	[taskSuccessOrNotCommandView_ removeFromSuperview];
		
	NSMutableString *maketa_txt = 
	[NSMutableString stringWithFormat:NSLocalizedString(@"ha_chikaratsukita",@""),
	 NSLocalizedString(@"hero", @"")];
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:maketa_txt actionAtTextFinished:@selector(tweetOfWinOrLose:) userInfo:nil target:self];
}
-(void)escape{
	[taskSuccessOrNotCommandView_ removeFromSuperview];
	
	NSMutableString *nigedashita_txt = 
	[NSMutableString stringWithFormat:NSLocalizedString(@"ha_nigedashita!",@""),
	 NSLocalizedString(@"hero", @"")];
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:nigedashita_txt actionAtTextFinished:@selector(avoidBattle) userInfo:nil target:self];
	
}
//勝ったか負けたかをツイートする。
-(void)tweetOfWinOrLose:(BOOL)win{
    //twitterアカウントが設定されていればTweetする。
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"twitter_username"]){
        TwitterManager *twitterManager = [[TwitterManager alloc]initWithDelegate:self];
        
        NSMutableString *post_txt;
        if(win){//勝ったとき            
            if(enemy_name_ && ![enemy_name_ isEqualToString:@""] && task_title_ && ![task_title_ isEqualToString:@""]){
                post_txt = 
                [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_win_battle_01",@""),
                 hero_name_,enemy_name_,task_title_];
            }else if (enemy_name_ && ![enemy_name_ isEqualToString:@""] && (!task_title_ || [task_title_ isEqualToString:@""])){
                post_txt = 
                [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_win_battle_02",@""),
                 hero_name_,enemy_name_];
            }else if ((!enemy_name_ || [enemy_name_ isEqualToString:@""]) && task_title_ && ![task_title_ isEqualToString:@""]){
                post_txt = 
                [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_win_battle_03",@""),
                 hero_name_,task_title_];
            }else{
                post_txt = 
                [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_win_battle_01",@""),
                 hero_name_,enemy_name_at_tweet_,task_title_at_tweet_];
            }
        }else{//負けたとき
            post_txt = 
            [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_lose_battle",@""),
             hero_name_ ];
        }
        
        BOOL success = [twitterManager postTweet:post_txt withCoordinate:task_coodinate_];
        if(success){
            [self tweetCompleted];
        }else {
            [self tweetFailed];
        }
        [twitterManager release];
    }
    //twitterアカウントが設定されていなければ、Tweetせずに終了
    else{
        [wWYViewController_ taskBattleComplete];
    }
}

-(void)tweetCompleted{
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:NSLocalizedString(@"tweeted_battle_result", @"") 
	   actionAtTextFinished:@selector(taskBattleComplete) 
				   userInfo:nil target:wWYViewController_];
}
-(void)tweetFailed{
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:NSLocalizedString(@"tweet_failed", @"") 
	   actionAtTextFinished:@selector(taskBattleComplete) 
				   userInfo:nil target:wWYViewController_];
}

@end
