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
    if(_networkConnectionManager) [_networkConnectionManager release];
	if(_networkConnectionKeyForGoogle) [_networkConnectionKeyForGoogle release];
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame withWWYViewController:(WWYViewController*)wWYViewController{
	if (self = [super init]) {
		[wWYViewController retain];
		wWYViewController_ = wWYViewController;
		self.view.frame = frame;
		self.view.opaque = false;
		self.view.backgroundColor = [UIColor blackColor];		
        _networkConnectionManager = [[NetworkConnectionManager alloc]init];
		//liveView_を作成
		if(!liveView_) {
			liveView_ = [[LiveView alloc]initWithFrame:CGRectMake(10, 330, 300, 1) withDelegate:self withMaxColumn:3];
			liveView_.overflowMode = WWYLiveViewOverflowMode_noAction;
			[liveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを最初は表示しないように設定。
		}
        
        //monsterViewを生成
        if(!monsterView_) {
            monsterView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monster.png"]];
            //monsterView_.center = CGPointMake(self.view.center.x, self.view.frame.size.height*0.3);
            monsterView_.frame = CGRectMake((self.view.frame.size.width-192)/2, 50, 192, 192);
        }
    }
    return self;
}
//タスクをセットアップ。
-(void)setupTask:(WWYTask*)task{
    [task retain];
	task_ = task;
    
	//ヒーロー名(twitter username)//ヒーロー名のみdealoc時にリリース。ヒーロー名がなかった場合もななしではない。  
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
    
    //この時点で逆ジオコーディング取得を始めておく
    //過去に取得した住所URLがあったら破棄
	if(task_address_) [task_address_ autorelease];
    [self didGotLocationWithCoordinate:task_coodinate_];
}

//バトルを始めるかどうかユーザーに聞くstep1。
-(void)startBattleOrNotAtTask:(WWYTask*)task{
    [self setupTask:task];
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
//ユーザーに訪ねるステップはなしで、すぐにバトルを始める。
-(void)startBattleNow:(WWYTask*)task{
    [self setupTask:task];
    [self startBattle];
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
	
	[wWYViewController_ doneTheTaskWhenWin:task_.ID];
		
	NSMutableString *taoshita_txt = 
	[NSMutableString stringWithFormat:NSLocalizedString(@"wo_taoshita!",@""),enemy_name_at_battle_];
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:taoshita_txt actionAtTextFinished:@selector(tweetOfWinOrLose:) userInfo:(id)kCFBooleanTrue target:self];
}
-(void)lose{
	[taskSuccessOrNotCommandView_ removeFromSuperview];
    [wWYViewController_ snoozeTaskWhenLose:task_.ID];
    
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
    //twitterアカウントが設定されていればけいけんち足したり、Tweetする。
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"twitter_username"]){        
        TwitterManager *twitterManager = [[TwitterManager alloc]initWithDelegate:self];
        
        NSMutableString *post_txt;
        NSMutableString* post_txt_whenLevelUP = nil;
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
            
            //経験値を足す
            StatusManager *statusManager =[StatusManager statusManager];
            int level = [statusManager getIntegerParameterOfPlayerStatus:@"lv"];
            int exGain = [[AWBuiltInValuesManager builtInValuesManager] getGainExAtLevel:level];
            if (exGain > 0) {//けいけんちが獲得できたら
                [post_txt appendFormat:NSLocalizedString(@"space", @"")];
                [post_txt appendFormat:NSLocalizedString(@"twitt_post_when_ex_gained", @""),exGain];
                //レベルが上がったら
                if ([[StatusManager statusManager]levelUpWithGainEX:exGain]) {
                    int newLevel = [statusManager getIntegerParameterOfPlayerStatus:@"lv"];
                    NSString* title = [statusManager getTitle];
                    //レベルアップのTweet文言
                    post_txt_whenLevelUP = [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_level_up", @""),hero_name_,newLevel,title];
                }
            }
        }else{//負けたとき
            post_txt = 
            [NSMutableString stringWithFormat:NSLocalizedString(@"twitt_post_when_lose_battle",@""),
             hero_name_ ];
        }
        
        //この時点で逆ジオコーディングが完了していれば、住所もTweetする。
        if(task_address_ && ![task_address_ isEqualToString:@""]) [post_txt appendFormat:@" %@",task_address_];
        
        // Tweetする。
        BOOL success = [twitterManager postTweet:post_txt withCoordinate:task_coodinate_];
        //レベルアップしていればさらにTweet
        if (post_txt_whenLevelUP) {
            success = [twitterManager postTweet:post_txt_whenLevelUP withCoordinate:task_coodinate_];
        }
        
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
/*
#pragma mark 勝つか負けるかを選択した
-(void)didSelectWinOrLose:(BOOL)win{
    if(win) buttleWin_ = YES;
    else buttleWin_ = NO;
    
}*/

#pragma mark -
#pragma mark 逆ジオコーディング取得
-(void)didGotLocationWithCoordinate:(CLLocationCoordinate2D)coordinate{
    
	NSString* lat = [[NSNumber numberWithFloat:coordinate.latitude]stringValue];
	NSString* lng = [[NSNumber numberWithFloat:coordinate.longitude]stringValue];
	
	//キーがあったら前のリクエストを止めて、キーを破棄
	if(_networkConnectionKeyForGoogle) {
		[_networkConnectionManager cancelConnectionForKey:_networkConnectionKeyForGoogle];
		[_networkConnectionKeyForGoogle release];_networkConnectionKeyForGoogle = nil;
	}
	//ネットワークに接続する。接続uniqueKeyも取得。
	NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=true&language=ja&latlng=%@,%@", lat, lng] ;
	_networkConnectionKeyForGoogle = [_networkConnectionManager requestConnectionWithURL:url fromObj:self callbackMethod:@selector(didReceivedGeo:) mode:@"json"];
	[_networkConnectionKeyForGoogle retain];
}

#pragma mark 逆ジオコーディング取得完了
//geocodingが帰ってきたとき呼ばれる
-(void)didReceivedGeo:(id)data{
	//キーを破棄
	if(_networkConnectionKeyForGoogle) [_networkConnectionKeyForGoogle release];_networkConnectionKeyForGoogle = nil;
	
	NSDictionary *dataDict = (NSDictionary*)data;
    //NSLog(@"resultsDict:%@",resultsDict);
	
	if([[dataDict objectForKey:@"status"]isEqualToString:@"OK"]){//返ってきたステータスがOKなら
        NSMutableString* resultAddress = [[NSMutableString alloc]initWithString:@""];
        
        for (NSDictionary* resultDict in [dataDict objectForKey:@"results"]) {
            
        
//            //formatted_address（通常使われる住所）を取得
//            NSString* resultAddress = [resultDict objectForKey:@"formatted_address"];
//            [resultAddress retain];
//            //先頭の「日本, 」の文字列を検索して取り除く
//            NSString* searchString = @"日本, ";
//            NSRange searchResult = [resultAddress rangeOfString:searchString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [searchString length])];
//            if (searchResult.location != NSNotFound ) {
//                [resultAddress deleteCharactersInRange:NSMakeRange(searchResult.location, searchResult.length)];
//            }
            
            //"locality"（一般的に識別できる地域名）を取得
            NSArray *address_components = [resultDict objectForKey:@"address_components"];
            for(NSDictionary *address_part in address_components){
                if([[address_part objectForKey:@"types"]containsObject:@"locality"]){
                    [resultAddress insertString:[address_part objectForKey:@"long_name"] atIndex:0];
                }
            }
            //欲しいフォーマットの住所が取得できてれば終了、できてなければ次の候補へ
            if (![resultAddress isEqualToString:@""]) break;
        }
		task_address_ = resultAddress;
		
	}else {
		task_address_ = @"";
	}
    NSLog(task_address_);
}
#pragma mark # 一定時間ネットワークから結果が反ってこなかったときにに呼ばれる
-(void)networkConnectionDidFaild:(NSString*)keyString{
    if([keyString isEqualToString:_networkConnectionKeyForGoogle]){
      //  [self tweetOfWinOrLose:buttleWin_];
    }
}
@end
