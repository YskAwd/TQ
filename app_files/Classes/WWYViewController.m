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
@synthesize searchButton_;
@synthesize networkConnectionManager = networkConnectionManager_;
@synthesize locationButtonMode = locationButtonMode_;

- (void)dealloc {	
	if(adController_) [adController_ stopTimer];[adController_ autorelease];
	if(mapViewController_) [mapViewController_.view removeFromSuperview];[mapViewController_ release];
	if(configViewController_) [configViewController_.view removeFromSuperview];[configViewController_ release];
	if(toolBar_) [toolBar_ removeFromSuperview];[toolBar_ release];
	if(locationButton_) [locationButton_ release];[configButton_ release];[searchButton_ release];
	if(activityIndicatorView_) [activityIndicatorView_ removeFromSuperview];[activityIndicatorView_ release];
	if(searchBar_) [searchBar_ removeFromSuperview];[searchBar_ release];
	if(myLocationGetter_) [myLocationGetter_ stopUpdatingLocation];[myLocationGetter_ release];
	if(taskBattleManager_) [taskBattleManager_ release];
	if(taskViewController_) [taskViewController_.view removeFromSuperview];[taskViewController_ release];
	if(taskBattleViewController_) [taskBattleViewController_.view removeFromSuperview];[taskBattleViewController_ release];
	if(networkConnectionManager_) [networkConnectionManager_ release];
    [super dealloc];
}

- (id)init {
    if (self = [super init]) {
		myLocationGetter_ = [[MyLocationGetter alloc]init];
		myLocationGetter_.delegate_ = self;
		//ロケーションの検知を始める
		[myLocationGetter_ startUpdates];
		
		networkConnectionManager_ = [[NetworkConnectionManager alloc]init];
		
		taskBattleManager_ = [[TaskBattleManager alloc]init];
	}
    return self;
}

//ViewControlerメソッド************************************************************************

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Custom initialization
	
	//ツールバーとボタンを生成
	toolBar_ =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 416, 320, 44)];
	toolBar_.barStyle = UIBarStyleBlackOpaque;
	locationButtonMode_ = 0;
	locationButtonImg_location_ = [UIImage imageNamed:@"btn_location.png"];
	locationButtonImg_heading_ = [UIImage imageNamed:@"btn_heading.png"];
	locationButton_ = [[UIBarButtonItem alloc]initWithImage:locationButtonImg_location_ 
													  style:UIBarButtonItemStyleBordered target:self 
													 action:@selector(doLocationButtonAction)];
	locationButton_.width = 40;
	locationButton_.enabled = false;
	
	configButton_ = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"command",@"") 
													style:UIBarButtonItemStyleBordered target:self 
												   action:@selector(configModeOnOff)];
	
	/*configButton_ = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_config.png"] 
	 style:UIBarButtonItemStyleBordered target:self 
	 action:@selector(configModeOnOff)];
	 configButton_.width = 45;*/
	
	configButton_.enabled = false;
	
	searchButton_ = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
																 target:self 
																 action:@selector(searchBarShowOnOff)];
	searchButton_.style = UIBarButtonItemStyleBordered;
	searchButton_.width = 40;
	searchButton_.enabled = false;
	
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil action:nil]autorelease];
	
	[toolBar_ setItems:[NSArray arrayWithObjects:locationButton_,spacer,configButton_,spacer,searchButton_,nil]];
	
	/*UIBarButtonItem *spacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
	 target:nil action:nil]autorelease];
	 spacer.width = 8;
	 [toolBar_ setItems:[NSArray arrayWithObjects:locationButton_,spacer,configButton_,spacer,searchButton_,nil]];*/
	
	//activityIndicatorViewを生成
	activityIndicatorView_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView_.frame = CGRectMake(16, 429, 20, 20);
	[activityIndicatorView_ startAnimating];
	
	//searcBarを生成
	searchBar_ = [[UISearchBar alloc]initWithFrame:CGRectMake(0, -44, 320, 44)];
	searchBar_.showsCancelButton = YES;
	searchBar_.delegate = self;
	
	//mapViewを生成
	mapViewController_ = [[WWYMapViewController alloc]initWithViewFrame:CGRectMake(0, 0, 320, 420) parentViewController:self];
	
	//configViewを生成
	configViewController_ = [[ConfigViewController alloc]initWithViewFrame:CGRectMake(0, 460, 320, 440) parentViewController:self];
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

//Location関係*******************************************************************
//MyLocaitonGetterから新しいCLLocationが来たときに呼ばれる。
-(void)upDatesCLLocation:(CLLocation*)newLocation{
	[mapViewController_ upDatesCLLocation:newLocation];
	[self checkTaskAroundLocation:newLocation];
}
//MyLocaitonGetterから新しいCLHeadingが来たときに呼ばれる。
-(void)upDatesCLHeading:(CLHeading*)newHeading{
	[mapViewController_ upDatesCLHeading:newHeading];
}
-(void)stopCLHeading{
	[mapViewController_ stopCLHeading];
}

//mapViewController_.mapViewでの座標を変換するメソッド。（mapViewController_.mapView直接だと取得できないので）*******************************************************************
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

//ボタンに対応するAction*******************************************************************
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
		searchButton_.enabled = false;
	}else if(configButton_.style == UIBarButtonItemStyleDone){
		configButton_.style = UIBarButtonItemStyleBordered;
		[UIView beginAnimations:@"configViewHide" context:NULL];
		[UIView setAnimationDuration:0.5f];
		//[UIView setAnimationDidStopSelector:@selector(whenconfigViewClosed)];//->なぜかうまくいかん
		configViewController_.view.frame=CGRectMake(configViewController_.view.frame.origin.x, 460, configViewController_.view.frame.size.width, configViewController_.view.frame.size.height);
		[UIView commitAnimations];
		[configViewController_ resetToDefault];
		
		locationButton_.enabled = true;
		searchButton_.enabled = true;
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

//locationボタンを押したとき
-(void)doLocationButtonAction{
	[self doLocationButtonActionAtMode:locationButtonMode_+1];
}
//外部からlocationボタンを押したときのアクションを実行させるために呼ばれる
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
//外部からlocationButtonModeを設定するために呼ばれる。
-(void)setLocationButtonMode:(int)locationButtonMode{
	switch (locationButtonMode) {
		case WWYLocationButtonMode_OFF:
			locationButton_.style = UIBarButtonItemStyleBordered;
			locationButton_.image = locationButtonImg_location_;
			locationButtonMode_ = WWYLocationButtonMode_OFF;
			break;
		case WWYLocationButtonMode_LOCATION:
			locationButton_.style = UIBarButtonItemStyleDone;
			locationButton_.image = locationButtonImg_location_;
			locationButtonMode_ = WWYLocationButtonMode_LOCATION;
			break;
		case WWYLocationButtonMode_HEADING:
			locationButton_.style = UIBarButtonItemStyleDone;
			locationButton_.image = locationButtonImg_heading_;
			locationButtonMode_ = WWYLocationButtonMode_HEADING;
			break;
		default:
			break;
	}
}

//タスク追加等。ConfigViewControllerから呼ばれる*********************************
-(void)addTask{
	//taskViewController_を起動。
	configButton_.enabled = false;
	if(!taskViewController_) taskViewController_ = [[TaskViewController alloc]initWhenAddTaskWithViewFrame:CGRectMake(0, 0, 320, 460) wWYViewController:self];
	[mapViewController_ startAddAnotationWithTap];
}
-(void)taskBattleAreaDidEndFixing{
	//[mapViewController_ stopAddAnotationWithTap];
	[mapViewController_.mapView_ deselectAnnotation:mapViewController_.nowAddingAnnotation_ animated:NO];
	[taskViewController_ startTaskNameInput];
	[self.view addSubview:taskViewController_.view];
}
//タスク登録処理
-(BOOL)registerTask:(WWYTask*)task{
	BOOL success = NO;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	if(taskViewController_.taskViewMode == WWYTaskViewMode_ADD){//タスク新規追加の場合
		if(mapViewController_.nowAddingAnnotation_){
			mapViewController_.isAddAnotationWithTapMode_ = false;//まずタップで選ぶ機能をOFFに
			success = [helperDB insertTask:task];
			if(success){
				mapViewController_.nowAddingAnnotation_.title = task.title;
				mapViewController_.nowAddingAnnotation_.subtitle = task.description;
				//吹き出しの長さを調節するためにもう一度セレクトする
				[mapViewController_.mapView_ selectAnnotation:mapViewController_.nowAddingAnnotation_ animated:NO];
			}
		}
	}else if(taskViewController_.taskViewMode == WWYTaskViewMode_EDIT){//既存タスク編集の場合
		success = [helperDB updateTask:task];
		if(success){
			mapViewController_.nowEditingAnnotation_.title = task.title;
			mapViewController_.nowEditingAnnotation_.subtitle = task.description;
			//吹き出しの長さを調節するためにもう一度セレクトする
			[mapViewController_.mapView_ selectAnnotation:mapViewController_.nowEditingAnnotation_ animated:NO];
		}
	}
	[helperDB release];
	
	return success;
}
//タスク削除
-(BOOL)deleteTask:(int)taskID{
	BOOL success = NO;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	success = [helperDB deleteTask:taskID];
	if(success)[mapViewController_.mapView_ removeAnnotation:mapViewController_.nowEditingAnnotation_];
	[helperDB release];
	
	return success;	
}
//タスク追加フローを途中でキャンセル
-(void)addTaskCanceled{
	[mapViewController_ cancelAddAnotationWithTap];
	[taskViewController_ release]; taskViewController_ = nil;
	configButton_.enabled = true;
}
//タスク追加フロー全て完了
-(void)addTaskCompleted{
	[mapViewController_ completeAddAnotationWithTap];
	mapViewController_.nowEditingAnnotation_ = nil;
	[taskViewController_ release]; taskViewController_ = nil;
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	[helperDB updateTaskAnnotationsFromDB:mapViewController_];
	[helperDB release];
	[taskBattleManager_ updateTasks];
	configButton_.enabled = true;
}
//タスク修正開始
-(void)editTaskWithID:(int)taskID{
	NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!editTaskWithID:(int)taskID:%d",taskID);
	if(!taskViewController_){
		WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
		WWYTask* task = [helperDB getTaskFromDB:taskID];
		taskViewController_ = [[TaskViewController alloc]initWhenEditTask:task viewFrame:CGRectMake(0, 0, 320, 460) wWYViewController:self];
		[self.view addSubview:taskViewController_.view];
		[helperDB release];
	}
}

//タスクが近くにあるかどうかをチェックする。
-(void)checkTaskAroundLocation:(CLLocation*)location{
	if(!taskBattleManager_.isNowAttackingTask && !mapViewController_.isAddAnotationWithTapMode_
	   && configButton_.style == UIBarButtonItemStyleBordered && searchButton_.style == UIBarButtonItemStyleBordered){
		WWYTask *task = [taskBattleManager_ taskAroundLocation:location withInMeter:TASK_HIT_AREA_METER];
		if(task){
			if(!taskBattleViewController_) taskBattleViewController_ = [[TaskBattleViewController alloc]initWithFrame:CGRectMake(0, 0, 320, 460) withWWYViewController:self];
			configButton_.enabled = false; searchButton_.enabled = false;
			[taskBattleViewController_ startBattleOrNotAtTask:task];
			[task release];
		}
	}
}
//タスクを回避したとき呼ばれる
-(void)avoidedTaskBattle:(WWYTask*)task{
	[taskBattleManager_ snoozeTask:task];
	if(taskBattleViewController_) {
		[taskBattleViewController_.view removeFromSuperview];[taskBattleViewController_ release];taskBattleViewController_ = nil;
	}
	taskBattleManager_.isNowAttackingTask = NO;
	configButton_.enabled = true; searchButton_.enabled = true;
}
//タスクをDBからとりのぞく（勝ったときに呼ばれる）
-(void)removeTask:(int)taskID{
	if(taskBattleManager_) [taskBattleManager_ removeTask:taskID];
}

//タスクバトル終了
-(void)taskBattleComplete{
	[taskBattleViewController_.view removeFromSuperview];[taskBattleViewController_ release];taskBattleViewController_ = nil;
	configButton_.enabled = true; searchButton_.enabled = true;
}

//twitterの認証を始める
-(void)startTwitterAuthentication{
	configButton_.enabled = false; searchButton_.enabled = false;
	if(!twitterViewController_) twitterViewController_ = [[TwitterAuthViewController alloc]initWithViewFrame:self.view.frame delegate:self];
	[self.view addSubview:twitterViewController_.view];
	[twitterViewController_ startTwitterOAuth];
}
//twitterの認証が終わったとき、キャンセルされたとき呼ばれる
-(void)twitterAuthenticationEnded{
	[twitterViewController_.view removeFromSuperview];
	[twitterViewController_ release];
	twitterViewController_ = nil;
	configButton_.enabled = true; searchButton_.enabled = true;
}

/*
//debugModeメソッド*******************************************************************
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

//目的地検索のメソッッド。XMLパースなど*******************************************************************
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
//NSXMLParserのdelegateメソッド************************************************************************
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

//UISearchBarのdelegateメソッド************************************************************************
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
	[mySearchBar resignFirstResponder];//これでキーボードが消える！
	//mySearchBar.showsCancelButton = FALSE;
	
	[self hideSearchBar];
}


//その他のメソッド************************************************************************

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
	[adViewController_ preCloseAction];
	[adViewController_.view removeFromSuperview];
	[adViewController_ release]; adViewController_ = nil;
}

@end