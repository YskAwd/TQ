//
//  ConfigViewController.m
//  WWY
//
//  Created by awaBook on 09/10/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "WWYViewController.h"
#import "WWYCommandView.h"
#import "WWYCommandColumnView.h"
#import "WWYHelper_DB.h"
#import "URLConnectionGetter.h"
#import "LiveView.h"

@implementation ConfigViewController

/* このクラスのコマンドビューの扱い
基本のコマンドビュー configCommandView_ のみ一度生成したら破棄せずに使う。子のコマンドビューは、開く、閉じる毎に生成、破棄をする。
*/
- (id)initWithViewFrame:(CGRect)frame parentViewController:(WWYViewController*)pViewController {
    if (self = [super init]) {
		wWYViewController_ = pViewController;
		self.view.frame = frame;
		self.view.backgroundColor = [UIColor blackColor];
		
		//partyOrderArray_をalloc、init。
		partyOrderArray_ = [[NSMutableArray alloc]initWithCapacity:0];
		//locolo codeの宣伝のフラグ
		locoloAd_nameFlg_ = false, locoloAd_descriptionFlg_ = false, locoloAd_urlFlg_ = false, locoloAd_parseEnded_ = false;
	}
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	//基本のコマンドビューを作成する。
	CGFloat marginX = 10, marginY = 10; //marginY = 30
	CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
								 self.view.frame.size.width-marginX*2, self.view.frame.size.height);
	configCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame target:self maxColumnAtOnce:8];
	[configCommandView_ setTitle:NSLocalizedString(@"command",@"") withWidth:cmdFrame.size.width/2.8 withHeight:0];
	[configCommandView_ addCommand:NSLocalizedString(@"add_quest",@"") action:@selector(configCmd_Tapped:) userInfo:@"add_quest"];
    [configCommandView_ addCommand:NSLocalizedString(@"status",@"") action:@selector(configCmd_Tapped:) userInfo:@"status"];
    
    //「じゅもん」にはいるものが1つしかないので、「じゅもん」はいったん外しておく。コマンド増えてきたらまた使う
	//[configCommandView_ addCommand:NSLocalizedString(@"magic",@"") action:@selector(configCmd_Tapped:) userInfo:@"magic"];
	//「じゅもん」に入っていた過去の勇者をみる
    [configCommandView_ addCommand:NSLocalizedString(@"Looking_back_upon",@"") action:@selector(configCmd_Tapped:) userInfo:@"Looking_back_upon"];
    
    [configCommandView_ addCommand:NSLocalizedString(@"mapType",@"") action:@selector(configCmd_Tapped:) userInfo:@"mapType"];
    [configCommandView_ addCommand:NSLocalizedString(@"party",@"") action:@selector(configCmd_Tapped:) userInfo:@"party"];
	[configCommandView_ addCommand:NSLocalizedString(@"twitter_setting",@"") action:@selector(configCmd_Tapped:) userInfo:@"twitter_setting"];
    [configCommandView_ addCommand:NSLocalizedString(@"how_to_use",@"") action:@selector(configCmd_Tapped:) userInfo:@"how_to_use"];
	[configCommandView_ addCommand:NSLocalizedString(@"go_back",@"") action:@selector(configCmd_Tapped:) userInfo:@"go_back"];
	[self.view addSubview:configCommandView_];
	
	//下の方にview全体を隠す
	self.view.frame = CGRectMake(self.view.frame.origin.x, 480, self.view.frame.size.width, self.view.frame.size.height);	

}


//
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

-(void)changeMapTypeAndHideConfigView:(int)mapType{
	[wWYViewController_.mapViewController_ changeMapType:mapType];
	//操作後ひと呼吸置いてViewを隠すためにTimer設定。
	[NSTimer scheduledTimerWithTimeInterval:0.3f
												 target:self//これで自動的にretainCountが1増えている。
											   selector:@selector(configModeOff:)
											   userInfo:nil
												repeats:NO];
}
-(void)goCurrentLocationAndHideConfigView{
	[wWYViewController_.mapViewController_ setCenterAtCurrentLocation];
	//操作後ひと呼吸置いてViewを隠すためにTimer設定。
	[NSTimer scheduledTimerWithTimeInterval:0.3f
									 target:self//これで自動的にretainCountが1増えている。
								   selector:@selector(configModeOff:)
								   userInfo:nil
									repeats:NO];
}
-(void)goAnnotationPlaceAndHideConfigView:(int)annotationNo{
	//Ramiaアニメーション実装ver
	//操作後ひと呼吸置いてViewを隠すためにTimer設定。
	//ターゲットになるannotationをTimerのuserInfoとして渡す。
	NSArray* mapViewAnnotations = [wWYViewController_.mapViewController_ getPureAnnotations];
	id <MKAnnotation> target_annotations = [mapViewAnnotations objectAtIndex:annotationNo];
	//[target_annotations retain];//下記のようにtimerのuserInfoにセットすることで、retainCountが1増えるようなので、ここではretain不要。
	[NSTimer scheduledTimerWithTimeInterval:0.3f
									 target:self//これで自動的にretainCountが1増えている。
								   selector:@selector(configModeOffAndGoAnnotation:)
								   userInfo:target_annotations//これで自動的にretainCountが1増えている。
									repeats:NO];
	[mapViewAnnotations autorelease];
	
}
-(void)changePartyAndHideConfigView:(NSTimer*)timer{
	//timer破棄
	[timer invalidate];

	//party_resultCommandView_を非表示、解放
	[party_resultCommandView_ removeFromSuperview];
	[party_resultCommandView_ autorelease]; party_resultCommandView_ = nil;
	//party_selectCommandView_を非表示、解放
	[party_selectCommandView_ removeFromSuperview];
	[party_selectCommandView_ autorelease]; party_selectCommandView_ = nil;
	
	//partyの並び順をDBに格納
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	[helperDB updatePartyOrder:partyOrderArray_];
	//[helperDB release];
	
	//partyの並び順をDBから取得し、反映
	[helperDB reassignCharacterFromDB:wWYViewController_.mapViewController_];
	[helperDB release];
	
	
	
	//操作後ひと呼吸置いてViewを隠すためにTimer設定。
	[NSTimer scheduledTimerWithTimeInterval:0.3f
									 target:self//これで自動的にretainCountが1増えている。
								   selector:@selector(configModeOff:)
								   userInfo:nil
									repeats:NO];
}

-(void)configModeOff:(NSTimer*)timer{
	[wWYViewController_ configModeOnOff];
	[timer invalidate];
}
-(void)configModeOffAndGoAnnotation:(NSTimer*)timer{
	[wWYViewController_ configModeOnOff];
	id <MKAnnotation> target_annotations = [timer userInfo];
	[wWYViewController_.mapViewController_ goAnnotation:target_annotations];

	[timer invalidate];
}

-(void)configCmd_Tapped:(NSString*)cmdStr{
	if([cmdStr isEqualToString:@"add_quest"]){//**********"たすく　ついか　ついか"がタップされたら
		//WWYViewControllerからこのビューを非表示にし、AddQuestViewをオープン
		[wWYViewController_ configModeOnOff];
		[wWYViewController_ addTask];
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略
    }else if([cmdStr isEqualToString:@"status"]){//**********"つよさ"がタップされたら
        //statusView_を作る。
        if(!statusView_){
            CGFloat marginX = 10, marginY = 10; 
            CGRect statusFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
                                            self.view.frame.size.width-marginX*2, self.view.frame.size.height*0.8);
            statusView_ = [[WWYStatusView alloc]initWithFrame:statusFrame];
        }
        if(!statusCommandView_){
			//statusCommandView_を作る。
			CGFloat marginX = 0, marginY = 152; 
			CGRect cmdFrame = CGRectMake(self.view.frame.size.width*3/5-marginX,self.view.frame.size.height-marginY,
										 self.view.frame.size.width*2/5, self.view.frame.size.height);
			statusCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame target:self maxColumnAtOnce:1];
			[statusCommandView_ addCommand:NSLocalizedString(@"go_back",@"") action:@selector(statusCmd_Tapped:) userInfo:@"go_back"];
            [statusCommandView_ columnViewArrowStartBlinking:0];
		}else{//すでにあったらデフォルトの状態にリセットする
			//[statusCommandView_ resetToDefault];//今のところページ送りないので省略
		}
        [self.view addSubview:statusView_];
		[self.view addSubview:statusCommandView_];
        
	}else if([cmdStr isEqualToString:@"mapType"]){//**********"まっぷたいぷ"がタップされたら
		if(!mapTypeCommandView_){
			//mapTypeCommandView_を作る。
			CGFloat marginX = 40, marginY = 90; 
			CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
										 self.view.frame.size.width-marginX*2, self.view.frame.size.height);
			mapTypeCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame target:self maxColumnAtOnce:4];
			[mapTypeCommandView_ addCommand:NSLocalizedString(@"mapType_Standard",@"") action:@selector(mapTypCmd_Tapped:) userInfo:[NSNumber numberWithInt:0]];
			[mapTypeCommandView_ addCommand:NSLocalizedString(@"mapType_Satellite",@"") action:@selector(mapTypCmd_Tapped:) userInfo:[NSNumber numberWithInt:1]];
			[mapTypeCommandView_ addCommand:NSLocalizedString(@"mapType_Hybrid",@"") action:@selector(mapTypCmd_Tapped:) userInfo:[NSNumber numberWithInt:2]];
			[mapTypeCommandView_ addCommand:NSLocalizedString(@"go_back",@"") action:@selector(mapTypCmd_Tapped:) userInfo:[NSNumber numberWithInt:3]];
		}else{//すでにあったらデフォルトの状態にリセットする
			//[mapTypeCommandView_ resetToDefault];//今のところページ送りないので省略
		}
		[self.view addSubview:mapTypeCommandView_];
		
	}else if([cmdStr isEqualToString:@"magic"]){//**********"じゅもん"タップされたら
		if(!magicCommandView_){
			//magicTypeCommandViewを作る。commandViewIdは2。
			NSMutableArray* cmdTxtArray = [[NSMutableArray alloc]initWithObjects:
										   NSLocalizedString(@"loula",@""),
                                           NSLocalizedString(@"Looking_back_upon",@""),
                                           NSLocalizedString(@"check_other_heroes",@""),
										   nil];
			if(locoloAd_parseEnded_){
                // ロコロ音源へのリンクは外しておく
				//[cmdTxtArray addObject:NSLocalizedString(@"locolo_music",@"")];
			}
			[cmdTxtArray addObject:NSLocalizedString(@"go_back",@"")];
			
			CGFloat marginX = 40, marginY = 125; 
			CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
										 self.view.frame.size.width-marginX*2, self.view.frame.size.height);
			magicCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:5 withDelegate:self withCommandViewId:2];
			[cmdTxtArray release];	
		}else{//あったらデフォルトの状態にリセットする
			//[magicCommandView_ resetToDefault];//今のところページ送りないので省略
		}
		[self.view addSubview:magicCommandView_];
    
    }else if([cmdStr isEqualToString:@"Looking_back_upon"]){//*********"かこのゆうしゃをみる"がタップされたら
        [self lookingBackUponTapped];
	}else if([cmdStr isEqualToString:@"party"]){//*********"並び替え"がタップされたら
		if(!party_selectCommandView_){
			//party_selectCommandView_を作る。commandViewIdは4。
			NSArray* cmdTxtArray = [[NSArray alloc]initWithObjects:
									NSLocalizedString(@"hero",@""),
									NSLocalizedString(@"soldier",@""),
									NSLocalizedString(@"pilgrim",@""),
									NSLocalizedString(@"wizard",@""),
									NSLocalizedString(@"fighter",@""),
									NSLocalizedString(@"merchant",@""),
									NSLocalizedString(@"goof_off",@""),
									NSLocalizedString(@"sage",@""),
									NSLocalizedString(@"cancel",@""),
									nil];
			
			CGFloat marginX = 5, marginY = 50; 
			CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
										 self.view.frame.size.width/2-marginX, self.view.frame.size.height);
			party_selectCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:9 withDelegate:self withCommandViewId:4];
			[cmdTxtArray release];
			
			//columnIdをセット。charaTypeは1から始まるので注意。
			NSMutableArray* clmIDArray = [[NSMutableArray alloc]initWithCapacity:1];
			for(int i = 0; i<9; i++){
				[clmIDArray addObject:[NSNumber numberWithInt:i+1]];
			}
			[party_selectCommandView_ setIDForColumnsFromNSNumberArray:clmIDArray];
			[clmIDArray release];
			
			//NSString* title = NSLocalizedString(@"party",@"");
			NSString* title = NSLocalizedString(@"select",@"");
			[party_selectCommandView_ setTitle:title withWidth:cmdFrame.size.width*3/5 withHeight:0];
		}else{//あったらデフォルトの状態にリセットする
			//[party_selectCommandView_ resetToDefault];//今のところページ送りないので省略
		}
		[self.view addSubview:party_selectCommandView_];
	}else if([cmdStr isEqualToString:@"twitter_setting"]){//**********"ついったー"がタップされたら
		if(!twitterSettingCommandView_){
			//twitterSettingCommandView_を作る。
			CGFloat marginX = 5, marginY = 90; 
			CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
										 self.view.frame.size.width-marginX*2, self.view.frame.size.height);
			twitterSettingCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame target:self maxColumnAtOnce:2];
			[twitterSettingCommandView_ addCommand:NSLocalizedString(@"twitter_authentication",@"") action:@selector(twitSettingCmd_Tapped:) userInfo:@"twitter_authentication"];
			[twitterSettingCommandView_ addCommand:NSLocalizedString(@"go_back",@"") action:@selector(twitSettingCmd_Tapped:) userInfo:@"go_back"];
		}else{//すでにあったらデフォルトの状態にリセットする
			//[twitterSettingCommandView_ resetToDefault];//今のところページ送りないので省略
		}
		[self.view addSubview:twitterSettingCommandView_];
    }else if([cmdStr isEqualToString:@"how_to_use"]){//********"あぷりのつかいかた"がタップされたら
        helpViewController_ = [[HelpViewController alloc]initWithViewFrame:self.view.bounds];
        helpViewController_.delegate = self;
        [self.view addSubview:helpViewController_.view];
	}else if([cmdStr isEqualToString:@"go_back"]){//********"もどる"がタップされたら
		//WWYViewControllerからビューを非表示に
		[wWYViewController_ configModeOnOff];
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略
	}
}
-(void)twitSettingCmd_Tapped:(NSString*)cmdStr{
	if([cmdStr isEqualToString:@"twitter_authentication"]){//ツイッター認証がたっぷされたら
		//WWYViewControllerからこのビューを非表示にし、Twitterのセッティングをオープン
		[wWYViewController_ configModeOnOff];
		[wWYViewController_ startTwitterAuthentication];
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略	
	}else{//戻るがたっぷされたら
		//twitterSettingCommandView_を非表示、解放
		[twitterSettingCommandView_ removeFromSuperview];
		[twitterSettingCommandView_ autorelease]; twitterSettingCommandView_ = nil;
		//configCommandView_を操作できるように
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略
		configCommandView_.touchEnable = true;
	}
}

-(void)mapTypCmd_Tapped:(NSNumber*)cmdNumber{
	int cmdIntNum = [cmdNumber intValue];
	if(cmdIntNum !=3){//********"もどる"以外がタップされたら
		//mapTypeCommandView_を非表示、解放
		[mapTypeCommandView_ removeFromSuperview];[mapTypeCommandView_ autorelease]; mapTypeCommandView_ = nil;
		//configCommandView_をリセット
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略
		[self changeMapTypeAndHideConfigView:cmdIntNum];
	}else{//"もどる"ならば
		//mapTypeCommandView_を非表示、解放
		[mapTypeCommandView_ removeFromSuperview];
		[mapTypeCommandView_ autorelease]; mapTypeCommandView_ = nil;
		//configCommandView_を操作できるように
		//[configCommandView_ resetToDefault];//今のところページ送りないので省略
		configCommandView_.touchEnable = true;
	}
}
	
-(void)statusCmd_Tapped:(NSString*)cmdStr{
    //statusCommandView_を非表示、解放
    [statusCommandView_ removeFromSuperview];
    [statusCommandView_ autorelease]; statusCommandView_ = nil;
    //statusView_を非表示、解放
    [statusView_ removeFromSuperview];
    [statusView_ autorelease]; statusView_ = nil;
    
    //configCommandView_を操作できるように
    //[configCommandView_ resetToDefault];//今のところページ送りないので省略
    configCommandView_.touchEnable = true;
}

//ヘルプ画面を閉じる
-(void)closeHelperView{
    [helpViewController_.view removeFromSuperview];
    [helpViewController_ release];helpViewController_ = nil;
    //configCommandView_を操作できるように
    //[configCommandView_ resetToDefault];//今のところページ送りないので省略
    configCommandView_.touchEnable = true;
}

//かこをふりかえる　がタップされたとき
-(void)lookingBackUponTapped{
    //WWYViewControllerからこのビューを非表示にし、HistoryMapをオープン
    [wWYViewController_ configModeOnOff];
    [wWYViewController_ startHistoryMap];
    //[configCommandView_ resetToDefault];//今のところページ送りないので省略
}

//WWYCommandViewDelegateメソッド
//コマンドがタッチされたときに呼ばれる。
-(void)commandPushedWithCommandString:(NSString*)commandString withColumnNo:(int)columnNo withColumnID:(int)columnId withCommandViewId:(int)commandViewId{
	if(commandViewId == 0){//configCommandView_なら
	}else if(commandViewId == 1){//mapTypeCommandView_なら
	}else if(commandViewId == 2){//magicCommandView_なら
		if(columnNo == 0){//"ルーラ"なら
			if(!annotationCommandView_){
				//annotationCommandView_を作る。commandViewIdは3。
				//mapViewのannotations配列を使う
				//NSArray* mapViewAnnotations = [[wWYViewController_.mapViewController_ mapView_]annotations];//こうやっても、参照しただけなのでretainCount増えないことを確認した。
				NSArray* mapViewAnnotations = [wWYViewController_.mapViewController_ getPureAnnotations];
				if([mapViewAnnotations count] != 0) {//annotationが登録されていれば
					NSMutableArray* cmdTxtArray = [[NSMutableArray alloc]initWithCapacity:1];
					id<MKAnnotation> annotation;
					for(annotation in mapViewAnnotations){
						[cmdTxtArray addObject:[NSMutableString stringWithString:[annotation title]]];
					}
					[cmdTxtArray addObject:NSLocalizedString(@"to_current_location",@"")];
					[cmdTxtArray addObject:NSLocalizedString(@"go_back",@"")];			
					CGFloat marginX = 8, marginY = 40; 
					CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
												 self.view.frame.size.width-marginX*2, self.view.frame.size.height);
					annotationCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:9 withDelegate:self withCommandViewId:3];
					[cmdTxtArray release];	
					[mapViewAnnotations release];
					[self.view addSubview:annotationCommandView_];
				}else{//annotationが登録されていなければ
					[self alertForNoAnnotations];
					//[magicCommandView_ resetToDefault];//今のところページ送りないので省略
					magicCommandView_.touchEnable = true;
				}
			}else{//あったらデフォルトの状態にリセットする
				[annotationCommandView_ resetToDefault];
				[self.view addSubview:annotationCommandView_];
			}
        }else if([commandString isEqualToString:NSLocalizedString(@"Looking_back_upon",@"")]){//"かこをみる"ならば 
            [self lookingBackUponTapped];
        }else if([commandString isEqualToString:NSLocalizedString(@"check_other_heroes",@"")]){//"ほかのゆうしゃをみる"ならば 
                //WWYViewControllerからこのビューを非表示にし、WebViewをオープン
                [wWYViewController_ configModeOnOff];
                [wWYViewController_ startUpWebView:WEBSITE_OTHER_HEROES_URL];
                //[configCommandView_ resetToDefault];//今のところページ送りないので省略
                
		}else if([commandString isEqualToString:NSLocalizedString(@"locolo_music",@"")]){//"ふしぎなおんがく"ならば
			//locoloAdLiveView_を作成、表示、文章表示。
			//NSLog(locoloAd_description_);
			if(!locoloAdLiveView_) {
				//locoloAdLiveView_ = [[LiveView alloc]initWithFrame:CGRectMake(10, 220, 300, 1) withDelegate:self];
                locoloAdLiveView_ = [[LiveView alloc]initWithFrame:CGRectMake(10, 250, 300, 1) withDelegate:self withMaxColumn:4];
				locoloAdLiveView_.overflowMode = WWYLiveViewOverflowMode_delegateAction;
				[locoloAdLiveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを表示しないように設定。
			}
			[self.view addSubview:locoloAdLiveView_];
			[locoloAdLiveView_ setTextAndGo:locoloAd_description_ withTextID:1];

		}else if([commandString isEqualToString:NSLocalizedString(@"go_back",@"")]){//"もどる"ならば
			//magicCommandView_を非表示、解放
			[magicCommandView_ removeFromSuperview];
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//configCommandView_を操作できるように
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			configCommandView_.touchEnable = true; 
		}
	}else if(commandViewId == 3){//anotationCommandViewなら
		if([commandString isEqualToString:NSLocalizedString(@"to_current_location",@"")]){//"げんざいち"なら
			//annotationCommandView_とmagicCommandView_を非表示、解放
			[annotationCommandView_ removeFromSuperview];
			[magicCommandView_ removeFromSuperview];
			[annotationCommandView_ autorelease]; annotationCommandView_ = nil;
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//configCommandView_をリセット
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			//コマンド実行
			[self goCurrentLocationAndHideConfigView];
		}else if([commandString isEqualToString:NSLocalizedString(@"go_back",@"")]){//"もどる"ならば
			//annotationCommandView_を非表示、解放
			[annotationCommandView_ removeFromSuperview];
			[annotationCommandView_ autorelease]; annotationCommandView_ = nil;
			//magicCommandView_を操作できるように
			//[magicCommandView_ resetToDefault];//今のところページ送りないので省略
			magicCommandView_.touchEnable = true;
		}else{//annotationが選択されたなら
			//annotationCommandView_とmagicCommandView_を非表示、解放
			[annotationCommandView_ removeFromSuperview];
			[magicCommandView_ removeFromSuperview];
			[annotationCommandView_ autorelease]; annotationCommandView_ = nil;
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//configCommandView_をリセット
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			//コマンド実行
			[self goAnnotationPlaceAndHideConfigView:columnNo];
		}
	}else if(commandViewId == 4){//party_selectCommandView_なら
		if([commandString isEqualToString:NSLocalizedString(@"cancel",@"")]){//"やめる"ならば
			//party_selectCommandView_を非表示、解放
			if(party_selectCommandView_){
				[party_selectCommandView_ removeFromSuperview];
				[party_selectCommandView_ autorelease]; party_selectCommandView_ = nil;
			}
			//party_resultCommandView_を非表示、解放
			if(party_resultCommandView_){
				[party_resultCommandView_ removeFromSuperview];
				[party_resultCommandView_ autorelease]; party_resultCommandView_ = nil;
			}
			//configCommandView_を操作できるように
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			configCommandView_.touchEnable = true;
		}else{//"やめる"じゃなければ
			//cmdTxtArrayを作る
			NSMutableArray* cmdTxtArray;
			if(!party_resultCommandView_){//はじめてなら
				//party_resultCommandView_用のcmdTxtArrayを作成
				//NSLog(@"commandString rCOUNT: %d",[commandString retainCount]);/=>1
				cmdTxtArray = [[NSArray alloc]initWithObjects:
							   [NSString stringWithFormat: @"1:%@",commandString],
							   nil];
				//NSLog(@"commandString rCOUNT: %d",[commandString retainCount]);/=>1
				
				//並び順をpartyOrderArray_に格納
				[partyOrderArray_ removeAllObjects];
				[partyOrderArray_ addObject:[NSNumber numberWithInt:columnId]];
			}else{//はじめてじゃなければ
				//party_resultCommandView_.commandColumnArrayをもとに、新しいcmdTxtArrayを作る
				cmdTxtArray =  [[NSMutableArray alloc]initWithCapacity:0];
				WWYCommandColumnView* cColumnView;
				for(cColumnView in party_resultCommandView_.commandColumnArray){
					[cmdTxtArray addObject:[cColumnView text]];
				}
				[cmdTxtArray addObject:[NSString stringWithFormat:@"%d:%@",[party_resultCommandView_.commandColumnArray count]+1,commandString]];
				
				//並び順をpartyOrderArray_に格納
				[partyOrderArray_ addObject:[NSNumber numberWithInt:columnId]];
			}
			
			//party_resultCommandView_を作る
			if(party_resultCommandView_){//もしすでにあるなら
				//party_resultCommandView_を非表示、解放
				[party_resultCommandView_ removeFromSuperview];
				[party_resultCommandView_ autorelease]; party_resultCommandView_ = nil;
			}
			//party_resultCommandView_を作る。（2回目以降の場合ももう一度作る）
			if(!party_resultCommandView_){
				//party_resultCommandView_を作る。commandViewIdは5。
				
				CGFloat marginX = 165, marginY = 50; 
				CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
											 self.view.frame.size.width/2-abs(160-marginX), self.view.frame.size.height);
				party_resultCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:4 withDelegate:self withCommandViewId:5];
				[cmdTxtArray release];
				party_resultCommandView_.touchEnable = false;
				NSString* title = NSLocalizedString(@"result",@"");
				[party_resultCommandView_ setTitle:title withWidth:cmdFrame.size.width*3/5 withHeight:0];
			}
			[self.view addSubview:party_resultCommandView_];
			
			if([party_resultCommandView_.commandColumnArray count] < 4){//これまでに選んだ人数が4人未満ならば
				//party_selectCommandView_を操作できるように
				//[party_selectCommandView_ resetToDefault];//今のところページ送りないので省略
				party_selectCommandView_.touchEnable = true;
			}else{//4人選んだら
				//結果確認する時間をとるため、Timer設定。Timerで呼び出される関数で当該CommandViewを非表示にして、コマンド実行。
				[NSTimer scheduledTimerWithTimeInterval:0.5f
												 target:self//これで自動的にretainCountが1増えている。
											   selector:@selector(changePartyAndHideConfigView:)
											   userInfo:nil
												repeats:NO];
			}
		}
	}else if(commandViewId == 6){//locoloAdContinueCommandView_なら
		if([commandString isEqualToString:NSLocalizedString(@"bring_forward",@"")]){//"つづける"ならば（locoloAdLiveView_の次の文章を見る）
			//locoloAdContinueCommandView_を非表示、解放
			[locoloAdContinueCommandView_ removeFromSuperview];
			[locoloAdContinueCommandView_ autorelease]; locoloAdContinueCommandView_ = nil;
			//locoloAdLiveView_の次の文章を見る
			[locoloAdLiveView_ goNextText];
		}else if([commandString isEqualToString:NSLocalizedString(@"go_back",@"")]){//"もどる"ならば（locoloAdLiveView_の次の文章は見ずconfigCommandView_まで戻る）
			//locoloAdContinueCommandView_を非表示、解放
			[locoloAdContinueCommandView_ removeFromSuperview];
			[locoloAdContinueCommandView_ autorelease]; locoloAdContinueCommandView_ = nil;
			//locoloAdLiveView_を非表示、解放
			[locoloAdLiveView_ removeFromSuperview];
			[locoloAdLiveView_ close];
			[locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
			//magicCommandView_を非表示、解放
			[magicCommandView_ removeFromSuperview];
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//configCommandView_を操作できるように
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			configCommandView_.touchEnable = true; 
			
			//じゅもんを選ぶ操作に戻るなら以下。
			/*
			 //locoloAdContinueCommandView_を非表示、解放
			 [locoloAdContinueCommandView_ removeFromSuperview];
			 [locoloAdContinueCommandView_ autorelease]; locoloAdContinueCommandView_ = nil;
			 //locoloAdLiveView_を非表示、解放
			 [locoloAdLiveView_ removeFromSuperview];
			 [locoloAdLiveView_ close];
			 [locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
			 //magicCommandView_を操作できるように
			 //[magicCommandView_ resetToDefault];//今のところページ送りないので省略
			 magicCommandView_.touchEnable = true;
			 */
		}
	}else if(commandViewId == 7){//locoloAdYesNoCommandView_なら
		if([commandString isEqualToString:NSLocalizedString(@"yes",@"")]){//"はい"ならば（ロコロの宣伝を見に行く）
			//locoloAdYesNoCommandView_とmagicCommandView_を非表示、解放
			[locoloAdYesNoCommandView_ removeFromSuperview];
			[magicCommandView_ removeFromSuperview];
			[locoloAdYesNoCommandView_ autorelease]; locoloAdYesNoCommandView_ = nil;
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//locoloAdLiveView_を非表示、解放
			[locoloAdLiveView_ removeFromSuperview];
			[locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
			//configCommandView_をリセット
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略			
			configCommandView_.touchEnable = true;
			//コマンド実行（iTunesStoreへ）
			//NSLog(@"locoloAd_url_: %@",locoloAd_url_);
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:locoloAd_url_]];  
			//このViewを非表示に
			[wWYViewController_ configModeOnOff];
		}else if([commandString isEqualToString:NSLocalizedString(@"no",@"")]){//"いいえ"ならば（ロコロの宣伝は見に行かずconfigCommandView_まで戻る）
			//locoloAdYesNoCommandView_を非表示、解放
			[locoloAdYesNoCommandView_ removeFromSuperview];
			[locoloAdYesNoCommandView_ autorelease]; locoloAdYesNoCommandView_ = nil;
			//locoloAdLiveView_を非表示、解放
			[locoloAdLiveView_ removeFromSuperview];
			[locoloAdLiveView_ close];
			[locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
			//magicCommandView_を非表示、解放
			[magicCommandView_ removeFromSuperview];
			[magicCommandView_ autorelease]; magicCommandView_ = nil;
			//configCommandView_を操作できるように
			//[configCommandView_ resetToDefault];//今のところページ送りないので省略
			configCommandView_.touchEnable = true; 
			
			//じゅもんを選ぶ操作に戻るなら以下。
			/*
			//locoloAdYesNoCommandView_を非表示、解放
			[locoloAdYesNoCommandView_ removeFromSuperview];
			[locoloAdYesNoCommandView_ autorelease]; locoloAdYesNoCommandView_ = nil;
			//locoloAdLiveView_を非表示、解放
			[locoloAdLiveView_ removeFromSuperview];
			[locoloAdLiveView_ close];
			[locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
			//magicCommandView_を操作できるように
			//[magicCommandView_ resetToDefault];//今のところページ送りないので省略
			magicCommandView_.touchEnable = true;
			*/
		}
	}
}
//デフォルトの状態にする。外部から呼ぶ。
-(void)resetToDefault{
	//それぞれのViewを非表示、解放。順編集中にconfigButtonを押して閉じることもあるのでここに必要。
	if(mapTypeCommandView_){
		[mapTypeCommandView_ removeFromSuperview];
		[mapTypeCommandView_ autorelease]; mapTypeCommandView_ = nil;
	}
	if(magicCommandView_){
		[magicCommandView_ removeFromSuperview];
		[magicCommandView_ autorelease]; magicCommandView_ = nil;
	}
	if(annotationCommandView_){
		[annotationCommandView_ removeFromSuperview];
		[annotationCommandView_ autorelease]; annotationCommandView_ = nil;
	}
	if(party_selectCommandView_){
		[party_selectCommandView_ removeFromSuperview];
		[party_selectCommandView_ autorelease]; party_selectCommandView_ = nil;
	}
	if(party_resultCommandView_){
		[party_resultCommandView_ removeFromSuperview];
		[party_resultCommandView_ autorelease]; party_resultCommandView_ = nil;
	}
	if(locoloAdContinueCommandView_){
		[locoloAdContinueCommandView_ removeFromSuperview];
		[locoloAdContinueCommandView_ autorelease]; locoloAdContinueCommandView_ = nil;
	}
	if(locoloAdYesNoCommandView_){
		[locoloAdYesNoCommandView_ removeFromSuperview];
		[locoloAdYesNoCommandView_ autorelease]; locoloAdYesNoCommandView_ = nil;
	}
	if(locoloAdLiveView_){
		[locoloAdLiveView_ removeFromSuperview];
		[locoloAdLiveView_ close]; [locoloAdLiveView_ autorelease]; locoloAdLiveView_ = nil;
	}
	if(twitterSettingCommandView_){
		[twitterSettingCommandView_ removeFromSuperview];
		[twitterSettingCommandView_ autorelease]; twitterSettingCommandView_ = nil;
	}
    if(statusCommandView_){
		[statusCommandView_ removeFromSuperview];
		[statusCommandView_ autorelease]; statusCommandView_ = nil;
	}
	if(statusView_){
		[statusView_ removeFromSuperview];
		[statusView_ autorelease]; statusView_ = nil;
	}
	[self closeHelperView];
    
	[configCommandView_ resetToDefault];
	configCommandView_.touchEnable = true; 
}

//まだAnnotationが登録されていないことをアラート表示するメソッド
-(void)alertForNoAnnotations{
	//アラート表示
	UIAlertView *noAnnotationsAlert = [[UIAlertView alloc] initWithTitle:nil
																message:NSLocalizedString(@"AnnotationIsNothing",@"")
															   delegate:self
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
	[noAnnotationsAlert show];
	[noAnnotationsAlert release];
}

//urlConnection関係のメソッド*******************************************************************
//webに接続しlocoloの宣伝をとりにいくメソッド
-(void)getLocoloAd{
	//ユーザの言語を判定
	NSArray *languages = [NSLocale preferredLanguages];
	NSString *currentLanguage = [languages objectAtIndex:0];
	//NSLog(@"currentLanguage: %@", currentLanguage);
	
	//接続先url
	NSString* urlString;
	if([currentLanguage isEqualToString:@"ja"]){//ユーザの言語環境が日本語なら
		urlString = @"http://www.locolocode.com/with_the_hero_app/locolo_ad/locolo_ad_ja.xml";
	}else{//日本語以外なら
		urlString = @"http://www.locolocode.com/with_the_hero_app/locolo_ad/locolo_ad_en.xml";
	}
	//非同期ネットワーク接続処理。（URLConnectionGetterを使用）
	if(urlConnectionGetter_) {//もしまだネットからジオコード情報取得できてなかったらキャンセルして初期化
		[urlConnectionGetter_ cancel]; [urlConnectionGetter_ release]; urlConnectionGetter_ = nil;
	}
	urlConnectionGetter_ = [[URLConnectionGetter alloc]initWithDelegate:self];
	//このメソッドで実際にURLアクセスし、レスポンスを得る処理が始まる。
	[urlConnectionGetter_ requestURL:urlString];	
}
//URLConnectionGetterから呼ばれるメソッド（レスポンスを取得する）**********************************************
- (void)receivedDataFromNetwork:(NSData*)data URLConnectionGetter:(id)uRLConnectionGetter{
	//NSLog([[NSString alloc]initWithData:data encoding:4]);//これで実際に取得できた中身をコンソールに出力。
	xmlParser_ = [[NSXMLParser alloc]initWithData:data];
	[xmlParser_ setDelegate:self];
	[xmlParser_ parse];
	//if(xmlParser_) {NSLog(@"xmlParser_ retainCount: %d",[xmlParser_ retainCount]);}//->1
	//[xmlParser_ autorelease];//これやっちゃだめ。parse終わると自動解放されるのか？
}
//NSXMLParserのdelegateメソッド************************************************************************
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	//各要素が始まったのを検知したら、フラグをtureに。
	//NSLog(elementName);
	if([elementName isEqualToString:@"name"]){
		locoloAd_nameFlg_ = TRUE;
	}else if([elementName isEqualToString:@"description"]){
		locoloAd_descriptionFlg_ = TRUE;
	}else if([elementName isEqualToString:@"url"]){
		locoloAd_urlFlg_ = TRUE;
		//NSLog(@"href= %@",[attributeDict objectForKey:@"href"]);//属性はこうやってとる。例は <url href=""> の場合。
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//フラグでどの要素の中身かを判断して、変数に入れていく。
	//なんと、ここで来るstringは全部一度に来るわけではない。（長さにもよるが、英語では一回で全文字来るが、日本語ではとぎれとぎれでしかここには来ないよう）参考:http://www.electrodream.jp/iphonedev/index.php/2009/04/nsxmlparserで文字が切れてしまう/
	//なので追加分はappendStringで加えていく。
	//NSLog(string);
	if(locoloAd_nameFlg_){
		if(!locoloAd_name_){
			locoloAd_name_ = [[NSMutableString alloc]initWithString:string];
		}else{
			[locoloAd_name_ appendString:string];
		}
	}else if(locoloAd_descriptionFlg_){
		if(!locoloAd_description_){
			locoloAd_description_ = [[NSMutableString alloc]initWithString:string];
		}else{
			[locoloAd_description_ appendString:string];
		}
	}else if(locoloAd_urlFlg_){
		if(!locoloAd_url_){
			locoloAd_url_ = [[NSMutableString alloc]initWithString:string];
		}else{
			[locoloAd_url_ appendString:string];
		}
	}
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	//各要素が終わったのを検知したら、フラグをfalseに戻す。
	//NSLog(elementName);
	if([elementName isEqualToString:@"name"]){
		locoloAd_nameFlg_ = false;
	}else if([elementName isEqualToString:@"description"]){
		locoloAd_descriptionFlg_ = false;
	}else if([elementName isEqualToString:@"url"]){
		locoloAd_urlFlg_ = false;
	}
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
	//NSLog(@"parse ended!!");
	locoloAd_parseEnded_ = true;
	//パースが終わったら、urlConnectionGetter_を解放。
	if(urlConnectionGetter_) {//タイミングによっては上で既に初期化されてしまってる場合もある(かもしれない)ので、if文で
		[urlConnectionGetter_ cancel]; [urlConnectionGetter_ autorelease]; urlConnectionGetter_ = nil;
	}
}
//parserエラー検知メソッド
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError{
	NSLog(@"parse validationErrorOccurred!!!!!!!!!!!!!!!");
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	NSLog(@"parseErrorOccurred!!!!!!!!!!!!!!!");
	NSLog([parseError localizedDescription]);
}

//LiveViewDelegateのメソッド************************************************************************
//LiveViewのテキスト描画が終わったときに、delegateに通知するメソッド。描画テキストのIDをつけて通知。
//textIDがない場合は、textID=0で送信される。
- (void) liveViewDrawEndedWithID:(int)textID{
	if(textID == 1){//locolo codeの宣伝の文章の表示が終わったら
		if(!locoloAdYesNoCommandView_){
			//locoloAdYesNoCommandView_を作る。commandViewIdは7。
			NSArray* cmdTxtArray = [[NSArray alloc]initWithObjects:
									NSLocalizedString(@"yes",@""),
									NSLocalizedString(@"no",@""),
									nil];
			
			CGFloat marginX = 155, marginY = 120; //CGFloat marginX = 100, marginY = 130; 
			CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
										 self.view.frame.size.width-marginX-15, self.view.frame.size.height);
			locoloAdYesNoCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:4 withDelegate:self withCommandViewId:7];
			[cmdTxtArray release];
			[locoloAdYesNoCommandView_ columnViewArrowStartBlinking:0];//arrowボタン点滅
		}else{//すでにあったらデフォルトの状態にリセットする
			//[locoloAdYesNoCommandView_ resetToDefault];//今のところページ送りないので省略
		}
		[self.view addSubview:locoloAdYesNoCommandView_];
	}
}

//LiveViewのテキストがあふれたとき、delegateに通知するメソッド。
//LiveViewのoverflowModeがWWYLiveViewOverflowMode_delegateActionの場合のみ実行される。
//(テキストがあふれたときに、LiveViewのdelegateからのアクションによって次のテキストを表示するモードの時のみ実行されるということ)
- (void) liveViewTextDidOverflow{
	if(!locoloAdContinueCommandView_){
		//locoloAdContinueCommandView_を作る。commandViewIdは6。
		NSArray* cmdTxtArray = [[NSArray alloc]initWithObjects:
								NSLocalizedString(@"bring_forward",@""),
								NSLocalizedString(@"go_back",@""),
								nil];
		
		CGFloat marginX = 155, marginY = 120; //CGFloat marginX = 100, marginY = 130; 
		CGRect cmdFrame = CGRectMake(self.view.frame.origin.x+marginX,self.view.frame.origin.y+marginY,
									 self.view.frame.size.width-marginX-15, self.view.frame.size.height);
		locoloAdContinueCommandView_ = [[WWYCommandView alloc]initWithFrame:cmdFrame withCommandTextArray:cmdTxtArray withMaxColumn:4 withDelegate:self withCommandViewId:6];
		[locoloAdContinueCommandView_ columnViewArrowStartBlinking:0];//arrowボタン点滅
		[cmdTxtArray release];
	}else{//すでにあったらデフォルトの状態にリセットする
		//[locoloAdContinueCommandView_ resetToDefault];//今のところページ送りないので省略
	}
	[self.view addSubview:locoloAdContinueCommandView_];
	
}
//************************************************************************
- (void)dealloc {
	[self resetToDefault];//configCommandView_以外のViewはこのメソッドで解放される。
	if(xmlParser_) [xmlParser_ abortParsing];//[xmlParser_ release];//このリリースがいるかいらないか、テスト必要
	if(configCommandView_) [configCommandView_ removeFromSuperview]; [configCommandView_ autorelease];
	if(partyOrderArray_) [partyOrderArray_ release];
	if(locoloAd_name_) [locoloAd_name_ release];
	if(locoloAd_description_) [locoloAd_description_ release];
	if(locoloAd_url_) [locoloAd_url_ release];
    if(statusView_) [statusView_ release];
    if(helpViewController_) [helpViewController_ release];
    [super dealloc];
}

@end
