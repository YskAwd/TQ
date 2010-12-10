    //
//  WWYAdViewController2.m
//  WWY
//
//  Created by AWorkStation on 10/11/15.
//  Copyright 2010 Japan. All rights reserved.
//

#import "WWYAdViewController2.h"
#import "WWYViewController.h"
#import "WWYMapViewController.h"

@implementation WWYAdViewController2


- (void)dealloc {
	NSLog(@"[DEALLOC]%@",@"WWYAdViewController2");
	[_wWYViewController release];
    [super dealloc];
}


-(id)initWithViewFrame:(CGRect)frame wWYViewController:(WWYViewController*)wWYViewController{
	//-(id)initWhenNewTaskWithViewFrame:(CGRect)frame taskCoordinate:(CLLocationCoordinate2D)coordinate WWYViewController:(WWYViewController*)wWYViewController{
	if (self = [super init]) {
		// Custom initialization
		[wWYViewController retain];
		_wWYViewController = wWYViewController;
		
		//test
		_dokoikuBasicURL = @"http://nw.ads.doko.jp/haishin/a?i=SI03YSAK&ip=&u=&m=p&d=n&k=%E3%83%9B%E3%83%86%E3%83%AB&gk=1&g=j&c=1&r=2&is=b&rc=5&pg=test&hs=n&fq=d&nolog=1";
		//本番
		//_dokoikuBasicURL = @"http://nw.ads.doko.jp/haishin/a?i=SI03YSAK&ip=&u=&m=p&d=n&k=%E3%83%9B%E3%83%86%E3%83%AB&gk=1&g=j&c=1&r=2&is=b&rc=5&pg=WithTheHero&hs=n&fq=d";
		
		self.view.frame = frame;
		self.view.opaque = false;
		self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
		
		
		if(!_adTextLabel) {
			_adTextLabel = [[[UILabel alloc]init]autorelease];
			_adTextLabel.frame = CGRectMake(30, 2, frame.size.width-32, frame.size.height-4);
			_adTextLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
			_adTextLabel.textColor = [UIColor whiteColor];
			_adTextLabel.font = [UIFont systemFontOfSize:9];
			_adTextLabel.numberOfLines = 3;
			_adTextLabel.textAlignment = UITextAlignmentLeft;
			_adTextLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			//_adTextLabel.text = NSLocalizedString(@"adTest",@"");

		}
		
		/*if(!_ad_wakuImageView){
			_ad_wakuImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ad_waku_01.png"]]autorelease];
			//_ad_wakuImageView.frame = CGRectMake(27, 0, 390, 40);
			//_ad_wakuImageView.frame = CGRectMake(27, 0, _ad_wakuImageView.frame.size.width, _ad_wakuImageView.frame.size.height);
		}*/
		
		if(!_ad_iconImageView){
			_ad_iconImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ad_hotel.png"]]autorelease];
			_ad_iconImageView.frame = CGRectMake(5, 8, _ad_iconImageView.frame.size.width, _ad_iconImageView.frame.size.height);
		}
		if(!_adLinkButton){
			_adLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_adLinkButton.frame = _adTextLabel.frame;
			[_adLinkButton addTarget:self action:@selector(adLinkButtonTouchedDown) forControlEvents:UIControlEventTouchDown];
			[_adLinkButton addTarget:self action:@selector(adLinkButtonTouchedUpOutside) forControlEvents:UIControlEventTouchUpOutside];
			[_adLinkButton addTarget:self action:@selector(adLinkButtonTouchedUpInside) forControlEvents:UIControlEventTouchUpInside];

		}
		
		//[self.view addSubview:_ad_wakuImageView];
		[self.view addSubview:_ad_iconImageView];
		[self.view addSubview:_adTextLabel];
		[self.view addSubview:_adLinkButton];
		
		//一定時間後に広告を閉じるためのタイマー
		[self makeAndReset_CloseAdTimer];
		
		
		[self getAndShowAd];
	}
	return self;
}

//一定時間後に広告を閉じるためのタイマーを作成
-(void)makeAndReset_CloseAdTimer{
	if(_closeAdTimer) {
		if([_closeAdTimer isValid]) {
			[_closeAdTimer invalidate]; 
		}
		_closeAdTimer = nil;
	}
	_closeAdTimer = [NSTimer scheduledTimerWithTimeInterval:12.0f
													 target:self 
												   selector:@selector(closeRecruiteAdView:) 
												   userInfo:nil 
													repeats:NO];
}

//広告を閉じる準備
-(void)preCloseAction{
	if(_closeAdTimer) {
		if([_closeAdTimer isValid]) {
			[_closeAdTimer invalidate]; 
		}
		_closeAdTimer = nil;
	}
	//接続をキャンセル（接続中でもそうでなくても、以下実行すればnetworkConnectionManagerが判断してキャンセルしてくれる）
	if(_connectionKey) [_wWYViewController.networkConnectionManager cancelConnectionForKey:_connectionKey];
}

//広告をとってきて表示する
-(void)getAndShowAd{
	NSMutableString *dokoikuURL = [NSMutableString stringWithString:_dokoikuBasicURL];
	
/*	//現在地から
	CLLocation *location = [_wWYViewController getNowLocationForAd];
	[location retain];*/
	
	//MapViewの中心から
	CLLocationCoordinate2D mapCoordinate = _wWYViewController.mapViewController_.mapView_.centerCoordinate;

	
//	if(location){
		//緯度、軽度をミリセカンドに変換
		NSNumber *lat_ms = [NSNumber numberWithInt:(int)(mapCoordinate.latitude * 3600000)];
		NSNumber *lng_ms = [NSNumber numberWithInt:(int)(mapCoordinate.longitude * 3600000)];
		[dokoikuURL appendFormat:@"&x=%@&y=%@", [lng_ms stringValue], [lat_ms stringValue]];
	//}
	
//	NSLog(@"URL:%@",dokoikuURL);
	
	//ネットワークに接続する。接続uniqueKeyも取得。
	if(_connectionKey) [_connectionKey release];_connectionKey = nil;
	_connectionKey =[_wWYViewController.networkConnectionManager requestConnectionWithURL:dokoikuURL fromObj:self callbackMethod:@selector(didReceivedAd:) mode:@"direct_data"];
	[_connectionKey retain];
}

//広告を入れ替える
-(void)refreshAd{
	[self makeAndReset_CloseAdTimer];
	[self getAndShowAd];
}

-(void)didReceivedAd:(NSData*)data{
	_xmlParser = [[NSXMLParser alloc]initWithData:data];
	[_xmlParser setDelegate:self];
	[_xmlParser parse];
}
//広告を閉じる
-(void)closeRecruiteAdView:(NSTimer*)timer{
	[timer invalidate]; _closeAdTimer = nil;
	[_wWYViewController closeRecruiteAdView];
}

//広告ボタンのアクション1
-(void)adLinkButtonTouchedDown{
	_adTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
}
//広告ボタンのアクション2
-(void)adLinkButtonTouchedUpOutside{
	_adTextLabel.textColor = [UIColor whiteColor];
}
//広告ボタンのアクション3（リンクへ飛ぶ）
-(void)adLinkButtonTouchedUpInside{
	NSLog(@"%@",@"DO ADLINK!");
	_adTextLabel.textColor = [UIColor whiteColor];
	[_wWYViewController startUpWebView:_adURL];
}


//NSXMLParserのdelegateメソッド************************************************************************
//このクラスでParseするXMLはattributeに情報が入っているタイプ。シンプルにParseできる。
//さらに返ってくる<ad>要素を1つに指定しているためシンプル。

//各要素が始まったのを検知
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	
	if([elementName isEqualToString:@"ad"]){
		//_parseFlag_ad = TRUE;
		
		//各属性をNSLogで確認
		/*for (NSString* str in attributeDict) {
			NSLog(@"%@",str);
		}*/
		
		//各属性を取得し、広告文字列に。
		_adTextLabel.text = [NSString stringWithFormat:@"%@%@%@",[attributeDict objectForKey:@"adTitle"],[attributeDict objectForKey:@"adText1"],[attributeDict objectForKey:@"adText2"]];
		
		//リンク先URLを設定
		_adURL = [[attributeDict objectForKey:@"adUrl"]retain];
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
	//NSLog(@"parse ended!!");
/*
	//パースが終わったら、urlConnectionGetter_を解放。
	if(urlConnectionGetter_) {//タイミングによっては上で既に初期化されてしまってる場合もある(かもしれない)ので、if文で
		[urlConnectionGetter_ cancel]; [urlConnectionGetter_ autorelease]; urlConnectionGetter_ = nil;
	}
 */
	[_xmlParser autorelease];
}

//parserエラー検知メソッド
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError{
	NSLog(@"parse validationErrorOccurred!!!!!!!!!!!!!!!");
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	NSLog(@"parseErrorOccurred!!!!!!!!!!!!!!!");
	NSLog([parseError localizedDescription]);
}

//*******************************************************************************************//
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
