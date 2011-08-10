//
//  WWYMapViewController.m
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WWYMapViewController.h"
#import "WWYViewController.h"
#import "DebugViewController.h"
#import "CharacterView.h"
#import "MyLocationGetter.h"
#import "CharacterAnnotation.h"
#import "WWYHelper_DB.h"
#import "CatchTapOnMapView.h"

@implementation WWYMapViewController
@synthesize mapView_;
@synthesize characterAnnotationArray_;
@synthesize currentCLLocation_;
@synthesize nowOnRamia_;
@synthesize isAddAnotationWithTapMode_;
@synthesize nowAddingAnnotation_;
@synthesize nowEditingAnnotation_;

- (id)initWithViewFrame:(CGRect)frame parentViewController:(WWYViewController*)pViewController {
    if (self = [super init]) {
		wWYViewController_ = pViewController;
		self.view.frame = frame;
		mapFrame_ = CGRectMake((320-564)/4, (420-564)/4, 564, 564);
		
		nowOnRamia_ = false;
		nowReturningFromRamia_ = false;
		doesCharacterFollowCurrentLocation_ = true;
		
		userlocationUpdate_ = 0;
		
		//myLocationGetter_ = [[MyLocationGetter alloc]init];
		//myLocationGetter_.delegate_ = self;
		//（viewDidLoad後、現在地検知を開始する）
		
		//前回終了時のmapのregionを取得
		[self getMapRegionAtLastTime];
		
		//初回起動時ならば、日本列島を表示し、mapViewを作って表示する
		//（初回起動時の日本地図にこだわらなければ、このif文の中はいらない。）
		//（初回起動時でなければ、ロケーション見つかってからmapViewを生成、表示する。mapView表示時の地図画像取得高速化のため。Regionを行き来すると、地図画像取得に時間がかかる）
		if(last_time_mapRegion_not_exsist_ && !mapView_){
			//mapView_を生成、表示
			MKCoordinateRegion mapRegion = {latitude_atStart_,longitude_atStart_,latitudeDelta_atStart_,longitudeDelta_atStart_};
			[self makeMapViewWithFrame:mapFrame_ region:mapRegion];
			if(!catchTapOnMapView_) catchTapOnMapView_ = [[CatchTapOnMapView alloc]initWithFrame:mapFrame_ withDelegate:self];
			[self.view addSubview:catchTapOnMapView_];
			[catchTapOnMapView_ addSubview:mapView_];
		}else{//初回起動じゃなければロケーション見つかるまでロケーション取得中の旨表示
			NSString *imagePath = [[NSBundle mainBundle]pathForResource:@"nowLocating" ofType:@"png"];
			UIImage *nowLocatingImage = [UIImage imageWithContentsOfFile:imagePath];
			nowLocatingImageView_ = [[UIImageView alloc]initWithImage:nowLocatingImage];
			nowLocatingImageView_.frame = CGRectMake(0, -20, nowLocatingImage.size.width, nowLocatingImage.size.height);
			[self.view addSubview:nowLocatingImageView_];
		}
			
		
		//ロケーションの検知を始める
		//[myLocationGetter_ startUpdates];
		
	}
    return self;
}


//mapViewでの座標を変換するメソッド。mapVewとself.viewのサイズの違いは考慮せず変換。外部からも呼ばれる。（外部からmapViewに直接アクセスしても取得できないので）************
-(CGPoint)convertToPointFromLocation:(CLLocation*)location{
	CGPoint newPoint = [mapView_ convertCoordinate:location.coordinate toPointToView:mapView_];
	//newPoint.x += mapView_.frame.origin.x*2, newPoint.y += mapView_.frame.origin.y*2;
	return newPoint;
}
//mapViewでの座標を変換するメソッド。mapVewとself.viewのサイズの違いを考慮して変換。外部からも呼ばれる。（外部からmapViewに直接アクセスしても取得できないので）************
-(CGPoint)convertToPointFromCoordinate:(CLLocationCoordinate2D)coordinate{
	CGPoint newPoint = [mapView_ convertCoordinate:coordinate toPointToView:mapView_];
	newPoint.x += mapView_.frame.origin.x*2, newPoint.y += mapView_.frame.origin.y*2;
	return newPoint;
}
- (CLLocationCoordinate2D)convertToCoordinateFromPoint:(CGPoint)point{
	//point.x -= mapView_.frame.origin.x*2, point.y -= mapView_.frame.origin.y*2;
    point.x -= mapView_.frame.origin.x, point.y -= mapView_.frame.origin.y;
	CLLocationCoordinate2D newCoodinate = [mapView_ convertPoint:point toCoordinateFromView:mapView_];
	return newCoodinate;
}



//いろいろメソッド******************************************************************************
//mapView_を生成、表示
-(void)makeMapViewWithFrame:(CGRect)frame region:(MKCoordinateRegion)region{
	//mapView_を生成
	mapView_ = [[MKMapView alloc]initWithFrame:frame];
	mapView_.delegate = self;
	mapView_.showsUserLocation = YES;
	
	//mapのregionを設定
	[mapView_ setRegion:region animated:NO];
	
	//mapTypeを適用。
	if(mapType_atStart_)	[self changeMapType:mapType_atStart_];//スタンダードならなにもしない。（スタンダードならmapTypeは0）
	
	//annotationとタスクを、DBから読み込む。
	WWYHelper_DB *helper_db = [[WWYHelper_DB alloc]init];
	[helper_db getAnnotationsFromDB:self];
	[helper_db getTasksFromDB:self];
	[helper_db autorelease];//autoreleaseはいつもできるだけ最後に！（この一個前の行だとうまくいかなかった。）
	
	//アプリスタート時はmapViewに関わる各ボタンが押せないようになってるが、mapView表示したらそれらを有効に。
	wWYViewController_.configButton_.enabled = YES;//configButtonを有効に。
	wWYViewController_.searchButton_.enabled = YES;//searchButtonを有効に。	

}
//MyLocaitonGetterから新しいCLLocationが来たときに呼ばれる。
-(void)upDatesCLLocation:(CLLocation*)newLocation{
	if(fabs(newLocation.coordinate.latitude) < 90.0 && fabs(newLocation.coordinate.longitude) < 180.0){//lat,lngのとりうる範囲内のみに、一応限定。
		userlocationUpdate_ += 1;
		
		CLLocation* _newLocation = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
		if(userlocationUpdate_ == 1){
			
			//初回起動時ならば日本列島俯瞰のregionが表示されてるはずなので、現在地にzoomしたregionにsetする。
			if(last_time_mapRegion_not_exsist_ && mapView_){
				//mapRegionを設定
				MKCoordinateRegion mapRegion = {
				_newLocation.coordinate.latitude, _newLocation.coordinate.longitude, 0.014, 0.013} ;
				[mapView_ setRegion:mapRegion animated:NO];//アニメーション有効にすると、重いしキャラの位置決定のタイミングに間に合わないし、フリーズしやすい原因でもありそうだし、見た目もうっとおしいのでアニメーションはなし。
			}else if(!last_time_mapRegion_not_exsist_ && !mapView_){//初回起動時じゃなければ、ここでmapView_を生成、表示
				//mapView_を生成、表示
				//mapRegionは現在地に設定（前回終了時のマップの縮尺を活かす）
				MKCoordinateRegion mapRegion = {
				_newLocation.coordinate.latitude, _newLocation.coordinate.longitude, latitudeDelta_atStart_, longitudeDelta_atStart_} ;
				[self makeMapViewWithFrame:mapFrame_ region:mapRegion];
				if(!catchTapOnMapView_) catchTapOnMapView_ = [[CatchTapOnMapView alloc]initWithFrame:mapFrame_ withDelegate:self];
				[self.view addSubview:catchTapOnMapView_];
				[catchTapOnMapView_ addSubview:mapView_];
				
				//Now Locating... 表示を非表示、破棄
				if(nowLocatingImageView_) [nowLocatingImageView_ removeFromSuperview];[nowLocatingImageView_ release];nowLocatingImageView_ = nil;
			}
			
			
			//もしまだキャラクターが生成されてなければ、生成してmapView_にいれる
			if(!characterAnnotationArray_) {
				[self makeCharacterAndPutonMapviewAt:_newLocation.coordinate];
			}else{//もしもう生成されてたなら、キャラクターの位置をアプリスタート時の位置から現在地に移動する
				[self realignCharactersWithBaseCoordinate:_newLocation.coordinate withMode:2.0];
			}
			
			//アプリスタート時はlocationButtonが押せないようになってるが、位置情報取得できたらそれを有効に。
			if(!wWYViewController_.locationButton_.enabled) wWYViewController_.locationButton_.enabled = YES;//locationButtonを有効に。
			
			//ロード中インジケーターをstop。
			[wWYViewController_ activityIndicatorViewOnOff:NO];
			
			//location追随モードをOnに。
			[wWYViewController_ setLocationButtonMode:WWYLocationButtonMode_LOCATION];
			//[self setCenterAtCurrentLocation];
			[wWYViewController_ makeAdController];
		
		}else if(userlocationUpdate_ > 1){//2回目以降。 //3回目で正確な位置情報が分かるっぽい。決まってるのかどうかはわからんが・・位置情報の取得を無線LAN→基地局→GPS等と行ってるのか？だとしたら3回目とは限らん。
			//キャラクターに位置情報を供給。
			if(doesCharacterFollowCurrentLocation_){
				//現在のロケーションと新ロケーションの、ポイントベースの距離でx軸かy軸か、どちらが大きいかで最初に進む方向を分ける
				CGPoint currPoint;
				if(!currentCLLocation_) currPoint = [mapView_ convertCoordinate:[[characterAnnotationArray_ objectAtIndex:0]coordinate] toPointToView:mapView_];
				else currPoint = [mapView_ convertCoordinate:currentCLLocation_.coordinate toPointToView:mapView_];
				CGPoint nextPoint = [mapView_ convertCoordinate:newLocation.coordinate toPointToView:mapView_];
				int firstMoveDirection;
				if(fabs(nextPoint.x - currPoint.x) > fabs(nextPoint.y - currPoint.y)){
					firstMoveDirection = 1;
				}else{
					firstMoveDirection = 0;
				}
				
				[self makeRootDataTo:_newLocation.coordinate on:[characterAnnotationArray_ objectAtIndex:0] firstMoveDirection:firstMoveDirection];
				[self makeRootDataTo:[[characterAnnotationArray_ objectAtIndex:0]coordinate] on:[characterAnnotationArray_ objectAtIndex:1] firstMoveDirection:firstMoveDirection];
				[self makeRootDataTo:[[characterAnnotationArray_ objectAtIndex:1]coordinate] on:[characterAnnotationArray_ objectAtIndex:2] firstMoveDirection:firstMoveDirection];
				[self makeRootDataTo:[[characterAnnotationArray_ objectAtIndex:2]coordinate] on:[characterAnnotationArray_ objectAtIndex:3] firstMoveDirection:firstMoveDirection];
				//[[characterAnnotationArray_ objectAtIndex:0]makeRootDataTo:_newLocation.coordinate];
			}
		}
		//currentCLLocation_を設定
		if(currentCLLocation_){[currentCLLocation_ autorelease],currentCLLocation_ = nil;}//autorelease必要？
		currentCLLocation_ = [[CLLocation alloc]initWithLatitude:_newLocation.coordinate.latitude longitude:_newLocation.coordinate.longitude];
		[self logCurrentLocation];
		
		//locationボタンが現在地追随モードなら、現在地を中心に持ってくる
		if(wWYViewController_.locationButtonMode == WWYLocationButtonMode_LOCATION || wWYViewController_.locationButtonMode == WWYLocationButtonMode_HEADING){
			//[mapView_ setCenterCoordinate:mapView_.userLocation.coordinate animated:YES];
			//独自のCLlocationは取得できていても、タイミング的に、mapviewのuserlocationはまだ取得できていない場合があり、上のように書くとエラーになることがある。
			//取得できてない場合は、-180,-180の座標となり、"invalid Coordinate"とログに出てフリーズ。//取得できててもnewlocationと同じ値とは限らない。
			isJustFollowingLocation_ = YES;
			[mapView_ setCenterCoordinate:_newLocation.coordinate animated:YES];
		}
		//_newLocationをautoreleaseしておく
		[_newLocation autorelease];
	}
}
//MyLocaitonGetterから新しいCLHeadingが来たときに呼ばれる。
-(void)upDatesCLHeading:(CLHeading*)newHeading{
	[UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration:0.3];  
    mapView_.transform = CGAffineTransformMakeRotation(M_PI * (360 - newHeading.trueHeading) / 180.0f);  
    [UIView commitAnimations]; 
}
//コンパス追随をストップする
-(void)stopCLHeading{
	[UIView beginAnimations:nil context:NULL];  
    [UIView setAnimationDuration:0.3];  
    mapView_.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations]; 
}

//対象キャラクターの現在地から、目的地まで道筋のDataを作って、キャラクターに渡す。
//縦軸、横軸移動の順番について。ここで一括で指定すると、どこか妥協が必要。（ストレート／90度ターンをとるか、U字ターンをとるか）
//完璧目指すなら、やはりCharacterAnnotationでこのメソッド実装し、キャラ毎に個別にスマート判断。

//firstMoveDirectionが0なら縦移動 -> 横移動　の順。1ならその逆。2なら自動計算。
-(void)makeRootDataTo:(CLLocationCoordinate2D)_newCoordinate on:(CharacterAnnotation*)_characterAnnotation firstMoveDirection:(int)firstMoveDirection{
//-(void)makeRootDataTo:(CLLocationCoordinate2D)_newCoordinate on:(CharacterAnnotation*)_characterAnnotation{
	_characterAnnotation.overlapWithPrevCharacter = FALSE;
	
	//CLLocation* _currentLocation = [[CLLocation alloc]initWithLatitude:_characterAnnotation.coordinate.latitude longitude:_characterAnnotation.coordinate.longitude];
	//CLLocation* _newLocation = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude longitude:_newCoordinate.longitude];
	
	//現在のロケーションと新ロケーションの、Lat、Lngベースの距離
	CGFloat desLat = _newCoordinate.latitude - _characterAnnotation.coordinate.latitude;
	CGFloat desLng = _newCoordinate.longitude - _characterAnnotation.coordinate.longitude;
	
	//現在のロケーションと新ロケーションの、ポイントベースの距離
	/*CGPoint currPoint = [mapView_ convertCoordinate:_characterAnnotation.coordinate toPointToView:mapView_];
	CGPoint nextPoint = [mapView_ convertCoordinate:_newCoordinate toPointToView:mapView_];*/
	CGPoint currPoint = [self convertToPointFromCoordinate:_characterAnnotation.coordinate];
	CGPoint nextPoint = [self convertToPointFromCoordinate:_newCoordinate];
	CGFloat dis_point = sqrt(pow(nextPoint.x-currPoint.x, 2) + pow(nextPoint.y-currPoint.y, 2));
	
	//if(desLat != 0 || desLng != 0){//前回取得時と位置情報が同じじゃなければ
	if(dis_point >= 5.0){//ポイントベースの距離がキャラの大きさよりも大きければ
		//locationをPushしていく間隔。
		CGFloat span = 0.000030;//CGFloat span = 0.0001;
		//あまりに多くのlocationをPushする場合(newLocationが離れすぎている場合)、メモリ食う&キャラの移動スピードが付いていかないので、200個までのPushになるようSpanを調節
		//spanの最大値を200個から50個に変更。実質ほぼ全ての移動で道筋ポイントが50個になる？速度のバランス的にはOK。
		//道筋ポイント50個以下の移動の際も、速度的には問題なさそう。
		//これらの値は、このクラスのspanの初期値とCharacterAnnotationのtimerの間隔に左右されるので、それらを変更するときには注意。
		if(fabs(desLat/span) > 50 || fabs(desLng/span) > 50) {
			if(fabs(desLat) > fabs(desLng)){
				span = fabs(desLat/50);
			}else{
				span = fabs(desLng/50);
			}
		}
		
		int desLatFlg,desLngFlg;//下の式で使うための、1か-1かのフラグ
		if(desLat < 0) {desLatFlg = -1;}else{desLatFlg = 1;}
		if(desLng < 0) {desLngFlg = -1;}else{desLngFlg = 1;}
		
		//対象キャラが現在保持している道筋をクリア
		[_characterAnnotation clearRootData];
		//NSLog(@"fabs(desLng/span)%f",fabs(desLng/span));
		
		//firstMoveDirectionが2の場合は、縦横どちらが先かを計算する。
		if(firstMoveDirection == 2){
			//目的地へのxの距離とyの距離どちらが大きいかで、縦から移動するか横から移動するか順番を変える。
			if(fabs(nextPoint.x - currPoint.x) > fabs(nextPoint.y - currPoint.y)){
				firstMoveDirection = 0;
			}else{
				firstMoveDirection = 1;
			}
		}
		
		//firstMoveDirectionが0なら縦移動 -> 横移動　の順。firstMoveDirectionが0以外ならその逆。
		if(firstMoveDirection == 0){
			//横移動
			for(int i=0; i<fabs(desLng/span);i++) {
				CLLocation* tempLocation1 = [[CLLocation alloc]initWithLatitude:_characterAnnotation.coordinate.latitude
																	  longitude:_characterAnnotation.coordinate.longitude+span*i*desLngFlg];
				[tempLocation1 autorelease];
				[_characterAnnotation pushRootArray:tempLocation1];
			}
			CLLocation* tempLocation2 = [[CLLocation alloc]initWithLatitude:_characterAnnotation.coordinate.latitude
																  longitude:_newCoordinate.longitude];
			[tempLocation2 autorelease];
			[_characterAnnotation pushRootArray:tempLocation2];
			
			//縦移動
			for(int i=0; i<fabs(desLat/span);i++) {
				CLLocation* tempLocation3 = [[CLLocation alloc]initWithLatitude:_characterAnnotation.coordinate.latitude+span*i*desLatFlg
																	  longitude:_newCoordinate.longitude];
				[tempLocation3 autorelease];
				[_characterAnnotation pushRootArray:tempLocation3];
				
			}
			CLLocation* tempLocation4 = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude
																  longitude:_newCoordinate.longitude];
			[tempLocation4 autorelease];
			[_characterAnnotation pushRootArray:tempLocation4];
			
		}else{

			//縦移動
			for(int i=0; i<fabs(desLat/span);i++) {
				CLLocation* tempLocation3 = [[CLLocation alloc]initWithLatitude:_characterAnnotation.coordinate.latitude+span*i*desLatFlg
																	  longitude:_characterAnnotation.coordinate.longitude];
				[tempLocation3 autorelease];
				[_characterAnnotation pushRootArray:tempLocation3];
				
			}
			CLLocation* tempLocation4 = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude
																  longitude:_characterAnnotation.coordinate.longitude];
			[tempLocation4 autorelease];
			[_characterAnnotation pushRootArray:tempLocation4];
			
			//横移動
			for(int i=0; i<fabs(desLng/span);i++) {
				CLLocation* tempLocation1 = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude
																	  longitude:_characterAnnotation.coordinate.longitude+span*i*desLngFlg];
				[tempLocation1 autorelease];
				[_characterAnnotation pushRootArray:tempLocation1];
			}
			CLLocation* tempLocation2 = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude
																  longitude:_newCoordinate.longitude];
			[tempLocation2 autorelease];
			[_characterAnnotation pushRootArray:tempLocation2];
		}
			
		/*
		//対象が先頭のキャラだったら、currentCLLocation_を設定
		if(_characterAnnotation.Id == 0){
			if(currentCLLocation_){[currentCLLocation_ autorelease],currentCLLocation_ = nil;}//autorelease必要？
			currentCLLocation_ = [[CLLocation alloc]initWithLatitude:_newCoordinate.latitude longitude:_newCoordinate.longitude];
		}
		*/
	}
}

//キャラクターを生成して、MapViewにannotationとして入れる
-(void)makeCharacterAndPutonMapviewAt:(CLLocationCoordinate2D)coordinate{
	if(!characterAnnotationArray_){
		//DBからパーティの並び順を取得
		WWYHelper_DB* helper_db = [[WWYHelper_DB alloc]init];
		NSArray* partyOrderArray = [helper_db selectPartyOrder];
		//キャラクター生成
		characterAnnotationArray_ = [[NSMutableArray alloc]init];
		CGPoint charaPoint = [mapView_ convertCoordinate:coordinate toPointToView:mapView_];
		for (int i=0; i<[partyOrderArray count]; i++) {
			if(i > 0) charaPoint.y -= 40 * 0.9;
			CLLocationCoordinate2D charaCoodinate = [mapView_ convertPoint:charaPoint toCoordinateFromView:mapView_];
			[characterAnnotationArray_ addObject:[[CharacterAnnotation alloc]initWithLatitude:charaCoodinate.latitude longitude:charaCoodinate.longitude title:@"CHARACTER" subtitle:@"CHARACTER" withCharaType:[[partyOrderArray objectAtIndex:i]intValue] withID:i]];
			[[characterAnnotationArray_ objectAtIndex:i]autorelease];
			[[characterAnnotationArray_ objectAtIndex:i]setMyDeleg:self];
			[mapView_ addAnnotation:[characterAnnotationArray_ objectAtIndex:i]];
			if(i > 0){
				[[characterAnnotationArray_ objectAtIndex:i]setPrevCharacter:[characterAnnotationArray_ objectAtIndex:i-1]];
				[[characterAnnotationArray_ objectAtIndex:i-1]setNextCharacter:[characterAnnotationArray_ objectAtIndex:i]];
			}
		}
		[partyOrderArray release];
		[helper_db release];
	}
}

//キャラクター達の並び順を再整列する。基準のcoordinateと動作モードを引数に持つ
-(void)realignCharactersWithBaseCoordinate:(CLLocationCoordinate2D)coordinate withMode:(CGFloat)mode{
	//キャラクタが現在地に追随しないようフラグ設定
	doesCharacterFollowCurrentLocation_ = false;
	//基準のPoint（モードによっては使わないが）	
	CGPoint basePoint = [mapView_ convertCoordinate:coordinate toPointToView:mapView_];
	if(mode == 1.0){//一瞬で一点にキャラクタが重なる。アニメーション要素なし。キャラクタは下向き。
		CharacterAnnotation *cAnnotation;
		for(cAnnotation in characterAnnotationArray_){
			[cAnnotation clearRootData];
			[cAnnotation mustMove_enable];
			CLLocation *tmpLoc = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
			[cAnnotation pushRootArray:tmpLoc];
			[tmpLoc autorelease];
			[cAnnotation mustMove_disable];
			[[mapView_ viewForAnnotation:cAnnotation]turnDown];
		}
	}else if(mode == 2.0){//一瞬で下向きに一列に並ぶ。アニメーション要素なし。
		CGPoint charaPoint = basePoint;
		CharacterAnnotation *cAnnotation;
		for(cAnnotation in characterAnnotationArray_){
			CLLocationCoordinate2D charaCoordinate = [mapView_ convertPoint:charaPoint toCoordinateFromView:mapView_];
			[cAnnotation clearRootData];
			[cAnnotation mustMove_enable];
			CLLocation *tmpLoc = [[CLLocation alloc]initWithLatitude:charaCoordinate.latitude longitude:charaCoordinate.longitude];
			[cAnnotation pushRootArray:tmpLoc];
			[tmpLoc autorelease];
			charaPoint.y -= 40 *0.9;
			[cAnnotation mustMove_disable];
			[[mapView_ viewForAnnotation:cAnnotation]turnDown];
		}
	}
	//キャラクタが現在地に追随するようフラグ設定
	doesCharacterFollowCurrentLocation_ = true;
}

//WWYViewControllerからlocationボタンを押したときに呼ばれる。configViewControllwe等からは明示的にこの関数を直接呼ばれる。
-(void)setCenterAtCurrentLocation{
	//if(currentCLLocation_ && mapView_.userLocation){
	if(currentCLLocation_){
		[self logCurrentRegion];
		isJustFollowingLocation_ = YES;
		[mapView_ setCenterCoordinate:currentCLLocation_.coordinate animated:YES];
	}else{//currentCLLocation_ないときはボタン押せなくなってるはずなので、このケースはないとは思うが一応、現在地が見つからないとダイアログを出す処理を実装。
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:nil
								  message:NSLocalizedString(@"currentLocationNotFound",@"") delegate:nil
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	//ラーミアに乗ってるときにlocationボタンを押したとき。
	if(nowOnRamia_) {
		nowReturningFromRamia_ = true;//このフラグをもとにmapViewDelegateメソッドのregionDidChangeAnimatedでこの後の処理が呼び出される。
		nowOnRamia_ = false;
		
		//ルーラで移動していた目的地の選択解除、参照解除
		if(anno_destinationOfLoula_){
			[mapView_ deselectAnnotation:anno_destinationOfLoula_ animated:true];
			anno_destinationOfLoula_ = nil;//目的地を示す変数の参照を外す。参照するだけ、で統一している変数なので、release等は行わない。
		}
	}
}

//mapタイプを変更する
-(void)changeMapType:(int)type{
	if(type == 0){
		mapView_.mapType = MKMapTypeStandard;
	}else if(type == 1) {
		mapView_.mapType = MKMapTypeSatellite;
	}else if(type == 2) {
		mapView_.mapType = MKMapTypeHybrid;
	}
}

//annotationを選択してmapView_のセンターにする。外部から呼ばれる。（ConfigViewControllerなど）
-(void)goAnnotation:(id<MKAnnotation>)annotation{
	
	//locationアップデート時のsetCenter処理とかぶらないように、現在地を追随しないモードに変更。
	[wWYViewController_ doLocationButtonActionAtMode:WWYLocationButtonMode_OFF];
	
	if(characterAnnotationArray_){//キャラクター達がいれば
		
		anno_destinationOfLoula_ = annotation;//目的地の変数を設定。
		nowOnRamia_ = true;

		//ボタン操作できないように。
		wWYViewController_.locationButton_.enabled = false, wWYViewController_.searchButton_.enabled = false, wWYViewController_.configButton_.enabled = false;		
		//mapView_のスクロールとズームを禁止
		mapView_.scrollEnabled = false;
		mapView_.zoomEnabled = false;
		
		[mapView_ selectAnnotation:annotation animated:YES];
		
		//キャラクター達を非表示に
		CharacterAnnotation* cAnnotation;
		for(cAnnotation in characterAnnotationArray_){
			CharacterView *cView;
			cView = [mapView_ viewForAnnotation:cAnnotation];
			cView.hidden = true;
		}
		
		if(!ramiaAnnotation_){//ラーミアに乗ってなければ
			[mapView_ setCenterCoordinate:currentCLLocation_.coordinate animated:NO];
			
			//基準になるPoint
			CGPoint tempRootPoint;
			if(currentCLLocation_){
//				tempRootPoint = [mapView_ convertCoordinate:currentCLLocation_.coordinate toPointToView:mapView_];
				tempRootPoint = [self convertToPointFromCoordinate:currentCLLocation_.coordinate];
			}else{
				tempRootPoint = mapView_.center;
			}
			//tempRootPoint.x += mapView_.frame.origin.x*2, tempRootPoint.y += mapView_.frame.origin.y*2;
			
			//ラーミアの位置
			CGPoint ramiaPoint = tempRootPoint;
//			CLLocationCoordinate2D ramiaCoodinate = [mapView_ convertPoint:ramiaPoint toCoordinateFromView:mapView_];
			CLLocationCoordinate2D ramiaCoodinate = [self convertToCoordinateFromPoint:ramiaPoint];
			
			//ラーミアのCharacterAnnotationを生成、mapView_に登録。
			if(!ramiaAnnotation_){
				ramiaAnnotation_ = [[CharacterAnnotation alloc]initWithLatitude:ramiaCoodinate.latitude longitude:ramiaCoodinate.longitude title:@"WWYRamia" subtitle:@"WWYRamia" withCharaType:100 withID:100];
				[ramiaAnnotation_ setMyDeleg:self];
				[mapView_ addAnnotation:ramiaAnnotation_];
			}
			
			//一時的なラーミアのCharacterViewを作成、表示
			//ラーミアはannotationとしても加えるが、実機だと画面に描写される速度がまちまちなので、乗り込むアニメーションのときだけCharacterViewバージョンも重ねる。
			if(!ramiaDummyView_){
				id <MKAnnotation> dummyAnnotaion = [[NSObject alloc]init];
				ramiaDummyView_ = [[CharacterView alloc]initWithAnnotation:dummyAnnotaion reuseIdentifier:@"WWYRamia_dummy" withCharaType:100];
				[dummyAnnotaion autorelease];
			}
			ramiaDummyView_.center = ramiaPoint;
			[ramiaDummyView_ turnUp];
			
			//本物のラーミアビューを非表示にし、ダミーのラーミアを表示。
			ramiaAnnotation_.characterView_.hidden = true;
			[self.view addSubview:ramiaDummyView_];
			//[ramiaDummyView_ animationStop];//ラーミアのCharacterViewのアニメーションはstopしておく
			
			//一時的なキャラクターのViewを作成、表示
			if(!tempCharaViewArrayForRamia_) tempCharaViewArrayForRamia_ = [[NSMutableArray alloc]initWithCapacity:0];
			WWYHelper_DB *helper_db = [[WWYHelper_DB alloc]init];
			NSArray *partyOrderArray = [helper_db selectPartyOrder];
			CGPoint tempCharaPoint = tempRootPoint; tempCharaPoint.y += 40;
			NSNumber *orderNSNumber; int i = 0;
			for (orderNSNumber in partyOrderArray){
				id <MKAnnotation> dummyAnnotaion = [[NSObject alloc]init];
				[dummyAnnotaion autorelease];
				CharacterView *tempCharacterView = [[CharacterView alloc]initWithAnnotation:dummyAnnotaion reuseIdentifier:@"temp_chara" withCharaType:[orderNSNumber intValue]];
				[tempCharaViewArrayForRamia_ addObject:tempCharacterView];
				tempCharacterView.center = tempCharaPoint;
				[tempCharacterView turnUp];
				[self.view addSubview:tempCharacterView];
				//一時的なキャラクター達を、ラーミアのところまで歩かせるanimationを設定
				CGContextRef context = UIGraphicsGetCurrentContext();
				[UIView beginAnimations:@"tempCharaMoveToRamia" context:context];
				[UIView setAnimationDuration:0.5 * (i+1)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(whenRiddenOnRamia)];
				tempCharacterView.center = ramiaPoint;
				[UIView commitAnimations];
				
				tempCharaPoint.y += 40;
				i += 1;
			}
			[partyOrderArray release];
			[helper_db release];
		}else{//すでにラーミアに乗っていれば
			//ラーミアに乗るアニメーション等はスキップし、目的地へ移動。
			//目的地に移動するタイマーを作成。
			[NSTimer scheduledTimerWithTimeInterval:0.7f
											 target:self//これで自動的にretainCountが1増えている。invalidate時に1減る。
										   selector:@selector(goTo_anno_destinationOfLoula:)
										   userInfo:nil
											repeats:NO];
		}
	}else{//キャラクター達がいなければ
		//普通に目的地に移動するだけで終了。あとの処理は省かれる。
		[mapView_ setCenterCoordinate:annotation.coordinate animated:YES];
		[mapView_ selectAnnotation:annotation animated:YES];
	}
}

//「一時的なキャラクター達がラーミアの背中に乗るアニメーション」の実行後に呼び出される。くり返しで。
-(void)whenRiddenOnRamia{
	if(tempCharaViewArrayForRamia_){
		//一時的なキャラ達をViewから外し、破棄。
		//NSLog(@"temp_CharacterView RCOUNT :%d",[[tempCharaViewArrayForRamia_ objectAtIndex:0] retainCount]);//->3
		//一時的なキャラクタービューが解放しきれてないようだが・・・もう一個autorelease送るとフリーズ。なんでさ。
		//→それは破棄する前に内部タイマーを停止してないから！"close"メソッドでその辺うまく処理してくれる。
		[[tempCharaViewArrayForRamia_ objectAtIndex:0]removeFromSuperview];
		[[tempCharaViewArrayForRamia_ objectAtIndex:0]close];
		//[[tempCharaViewArrayForRamia_ objectAtIndex:0]autorelease];
		[tempCharaViewArrayForRamia_ removeObjectAtIndex:0];
		if([tempCharaViewArrayForRamia_ count] == 0){//最後のキャラクターがラーミアに乗ったら
			//ラーミアのCharacterViewを表示、アニメーションをstart
			if(ramiaAnnotation_.characterView_) {
				ramiaAnnotation_.characterView_.hidden = false;
				[ramiaAnnotation_.characterView_ animationStart];
			}
			
			//tempCharaViewArrayForRamia_を解放
			[tempCharaViewArrayForRamia_ release];tempCharaViewArrayForRamia_=nil;
			
			//ramiaDummyView_を非表示、解放
			[ramiaDummyView_ removeFromSuperview];
			[ramiaDummyView_ close];
			[ramiaDummyView_ release];ramiaDummyView_ = nil;
			
			//目的地に移動するタイマーを作成。
			[NSTimer scheduledTimerWithTimeInterval:0.5f
											 target:self//これで自動的にretainCountが1増えている。invalidate時に1減る？
										   selector:@selector(goTo_anno_destinationOfLoula:)
										   userInfo:nil
											repeats:NO];
		}
	}
}
//ルーラの時、ラーミア関係のアニメーションが全て終了した後に呼ばれる、目的地にmapの中心を移動するメソッド。
-(void)goTo_anno_destinationOfLoula:(NSTimer*)timer{
	[timer invalidate];
	if(anno_destinationOfLoula_ && ramiaAnnotation_) {
		//CGPoint destinationRamiaPoint = [mapView_ convertCoordinate:anno_destinationOfLoula_.coordinate toPointToView:mapView_];
		CGPoint destinationRamiaPoint = [self convertToPointFromCoordinate:anno_destinationOfLoula_.coordinate];
		destinationRamiaPoint.y += 60;
		CLLocationCoordinate2D destinationRamiaCoordinate = [self convertToCoordinateFromPoint:destinationRamiaPoint];
		[mapView_ setCenterCoordinate:anno_destinationOfLoula_.coordinate animated:YES];
		
		//ラーミアを移動
		//ラーミアの移動にアニメーション必要なければこっち
		/*
		CLLocation *tmpLocation = [[CLLocation alloc]initWithLatitude:destinationRamiaCoordinate.latitude longitude:destinationRamiaCoordinate.longitude];
		[ramiaAnnotation_ pushRootArray:tmpLocation];
		[tmpLocation autorelease];
		*/

		//ラーミアもアニメーション的に移動したければこっち
		
		[self makeRootDataTo:destinationRamiaCoordinate on:ramiaAnnotation_ firstMoveDirection:2];

	}
	//mapユーザ操作できるように。
	mapView_.scrollEnabled = true;
	mapView_.zoomEnabled = true;
	//ボタン操作できるように。
	wWYViewController_.locationButton_.enabled = true, wWYViewController_.searchButton_.enabled = true, wWYViewController_.configButton_.enabled = true;
	 
	//リクルート広告を表示
	[wWYViewController_ performSelector:@selector(showRecruitAd) withObject:nil afterDelay:2.0f];
}

//ルーラでラーミアから現在地に帰還したときに呼ばれる
-(void)returnedFromRamia{
	//ラーミアannotaionを破棄
	if(ramiaAnnotation_){		
		[mapView_ removeAnnotation:ramiaAnnotation_];
		[ramiaAnnotation_ close];//ラーミアのCharacterAnnotationインスタンスをclose
		[ramiaAnnotation_ autorelease];ramiaAnnotation_ = nil;
	}	
	
	//本物のキャラクター達を整列しておく（まだ非表示）
	[self realignCharactersWithBaseCoordinate:currentCLLocation_.coordinate withMode:1.0];

	//ラーミアdummiyViewを作成
	//ラーミアdummiyViewは、初期位置（生成）->基準位置（キャラを降ろすメソッド実行）->終了位置->破棄 という流れ
	//基準になるPoint
	CGPoint tempRootPoint;
	if(currentCLLocation_){
		//tempRootPoint = [mapView_ convertCoordinate:currentCLLocation_.coordinate toPointToView:mapView_];
		tempRootPoint = [self convertToPointFromCoordinate:currentCLLocation_.coordinate];
	}else{
		tempRootPoint = mapView_.center;
	}
	//ラーミアの基準位置
	CGPoint ramiaPoint = tempRootPoint;
	ramiaPoint.y -= 40;//*0.9*4;
	//CLLocationCoordinate2D ramiaCoordinate = [mapView_ convertPoint:ramiaPoint toCoordinateFromView:mapView_];
	CLLocationCoordinate2D ramiaCoordinate = [self convertToCoordinateFromPoint:ramiaPoint];
	//ラーミアの初期位置
	CGPoint ramiaStartPoint = ramiaPoint; ramiaStartPoint.x += 240;
	//ラーミアの終了位置
	//CGPoint ramiaEndPoint = ramiaPoint; ramiaEndPoint.x -= 240;//別メソッドで使うのでここで定義しても
	
	//生成
	if(!ramiaDummyView_){
		id <MKAnnotation> dummyAnnotaion = [[NSObject alloc]init];
		ramiaDummyView_ = [[CharacterView alloc]initWithAnnotation:dummyAnnotaion reuseIdentifier:@"WWYRamia_dummy" withCharaType:100];
		[dummyAnnotaion autorelease];
	}
	ramiaDummyView_.center = ramiaStartPoint;
	[ramiaDummyView_ turnLeft];
	[self.view addSubview:ramiaDummyView_];
	
	//ラーミアの基準位置へ移動、メソッド実行。続きの処理はそのメソッド内で。
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:@"ramiaDummyViewMove" context:context];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dropOffRamia)];
	ramiaDummyView_.center = ramiaPoint;
	[UIView commitAnimations];
}

-(void)dropOffRamia{
	
	//本物のキャラクター達の非表示を解除
	CharacterAnnotation* cAnnotation;
	for(cAnnotation in characterAnnotationArray_){
		CharacterView *cView;
		cView = [mapView_ viewForAnnotation:cAnnotation];
		cView.hidden = false;
	}
	
	//ラーミアを終了位置へ移動、メソッド実行。続きの処理はそのメソッド内で。
	CGPoint ramiaEndPoint = ramiaDummyView_.center; ramiaEndPoint.x -= 240;
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:@"ramiaDummyViewMoveOut" context:context];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(whenDroppedOffRamia)];
	ramiaDummyView_.center = ramiaEndPoint;
	[UIView commitAnimations];
}

//「キャラクター達がラーミアから降りるアニメーション」の実行後に呼び出される。
-(void)whenDroppedOffRamia{
	//ramiaDummyView_を非表示、解放
	[ramiaDummyView_ removeFromSuperview];
	[ramiaDummyView_ close];
	[ramiaDummyView_ release];ramiaDummyView_ = nil;
}
//annotationを追加するために呼ばれる（WWYViewControllerから等。旧互換のためのメソッド。）
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle moved:(BOOL)moved{
	WWYAnnotation* annotation = [self addAnnotationWithLat:latitude Lng:longitude title:title subtitle:subtitle annotationType:WWYAnnotationType_normal selected:NO moved:moved];
	return annotation;
}
//annotationを追加するために呼ばれる（WWYViewControllerから等。userInfoつき。）
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle annotationType:(int)annotationType userInfo:(id)userInfo selected:(BOOL)selected moved:(BOOL)moved{
	WWYAnnotation* annotation = [self addAnnotationWithLat:latitude Lng:longitude title:title subtitle:subtitle annotationType:annotationType selected:selected moved:moved];
	annotation.userInfo = userInfo;
	return annotation;
}
//annotationを追加するために呼ばれる（WWYViewControllerから等）
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle annotationType:(int)annotationType selected:(BOOL)selected moved:(BOOL)moved{
	WWYAnnotation* annotation = [[WWYAnnotation alloc]initWithLatitude:latitude longitude:longitude title:title subtitle:subtitle];
	annotation.annotationType = annotationType;
	[annotation autorelease];
			//NSLog(@"RCountWhenCreated: %d",[annotation retainCount]);//->1
	[mapView_ addAnnotation:annotation];
			//NSLog(@"RCountWhenAdded: %d",[annotation retainCount]);//->6 ここで一気にretainCountが5つも増えるが、MKMapViewが保持してるのか、正常値のよう。
	
	//mapView_のセンターをannotationの場所に移動(annotaionの場所が、現在描画中の場所じゃなかった場合のみ)
	if(moved){
		//CGPoint annoPoint = [mapView_ convertCoordinate:annotation.coordinate toPointToView:mapView_];
		CGPoint annoPoint = [self convertToPointFromCoordinate:annotation.coordinate];
		if(annoPoint.x < 0.0 || annoPoint.y < 0.0 || annoPoint.x > 320.0 || annoPoint.y > 420.0){//場所判定
			//locationアップデート時のsetCenter処理とかぶらないように、現在地を追随しないモードに変更。
			[wWYViewController_ doLocationButtonActionAtMode:WWYLocationButtonMode_OFF];
			[mapView_ setCenterCoordinate:annotation.coordinate animated:YES];
		}
	}
	
	//annotationを選択状態にする。ここで直接指定しても効かないので、0.5秒遅らせて、別メソッドで実行。
	if(selected){
		[self performSelector:@selector(selectAnnotation:) withObject:annotation afterDelay:0.5];
	}
	
	return annotation;
}

//annotaionを選択状態にする。（annotation追加時に実行しても効かなかったので別関数にした）
-(void)selectAnnotation:(id <MKAnnotation>)annotation{
	[mapView_ selectAnnotation:annotation animated:YES];
}

//DBに現在のmapRegionを書き込む。アプリ終了時等に利用。->余裕あったらWWYHelper_DBで処理するよう修正？
-(void)updateLastTimeMapRegion{
	//DBに終了時のmapRegionを書き込む。
	if(mapView_){
		latitude_atStart_ = mapView_.region.center.latitude;
		longitude_atStart_ = mapView_.region.center.longitude;
		latitudeDelta_atStart_ = mapView_.region.span.latitudeDelta;
		longitudeDelta_atStart_ = mapView_.region.span.longitudeDelta;
		
		//mapTypeを数値で格納するため、変換
		int mapType;
		if(mapView_.mapType == MKMapTypeStandard){
			mapType = 0;
		}else if(mapView_.mapType == MKMapTypeSatellite) {
			mapType = 1;
		}else if(mapView_.mapType == MKMapTypeHybrid) {
			mapType = 2;
		}
		
		//sql文を生成		
		NSMutableString* queryStr = [NSMutableString stringWithString:@"UPDATE last_time_mapRegion SET "];
		[queryStr appendString:[NSString stringWithFormat:@"latitude=%f",latitude_atStart_]];
		[queryStr appendString:[NSString stringWithFormat:@", longitude=%f",longitude_atStart_]];
		[queryStr appendString:[NSString stringWithFormat:@", latitudeDelta=%f",latitudeDelta_atStart_]];
		[queryStr appendString:[NSString stringWithFormat:@", longitudeDelta=%f",longitudeDelta_atStart_]];
		[queryStr appendString:[NSString stringWithFormat:@", mapType=%d",mapType]];
		[queryStr appendString:@" WHERE id=0"];
		
		NSLog(queryStr);
		
		//DBへ反映
		FMRMQDBUpdate* updateDB = [FMRMQDBUpdate alloc];
		[updateDB upDateDBWithQueryString:queryStr];
		//インスタンスをリリース
		[updateDB release];
	}
}

//mapView_のAnnotation管理。8つ以上あったら古いものから削除する。それをDBに反映する。
-(void)manageAnnotationsAmount{	
	id <MKAnnotation> annotation;
	int i =0;
	//DBに書き込むための、現在地とキャラクター以外のannotationを格納した一時的なarray。autoreleaseはこのメソッドの最後に書いてある。
	NSMutableArray *annotationArray = [self getPureAnnotations];
			//NSLog(@"annotationArray rCount1: %d",[annotationArray retainCount]);//->1
	
	//、現在地とキャラクター以外のannotationが9つ以上あるなら、古いものを削除する。
			if([annotationArray count] > 7){//8つ以上あるなら
				//**mapView_から古いannotationを削除**
				[mapView_ removeAnnotation:[annotationArray objectAtIndex:0]];
						//NSLog(@"annotation rCount when removed: %d",[[annotationArray objectAtIndex:0]retainCount]);//->2
						//[[annotationArray objectAtIndex:0]autorelease];//ここでautoreleaseすると落ちるので、retainCountのつじつまは合ってる模様。
				//**annotationArrayから古いannotationを削除**
				[annotationArray removeObjectAtIndex:0];
			}
	
	//annotationArrayの内容をDBに反映する
	if([annotationArray count] > 0){//annotationArrayの中身があれば
		//NSLog(@"annotationArray rCount1: %d",[annotationArray retainCount]);//->1
		WWYHelper_DB *helper_db = [[WWYHelper_DB alloc]init];
		[helper_db autorelease];
		[helper_db updateAnnotations:annotationArray];
		//NSLog(@"annotationArray rCount2: %d",[annotationArray retainCount]);//->1
	}
		[annotationArray autorelease];
}

//現在地とキャラクター以外のannotations配列を取得する。
-(NSArray*)getPureAnnotations{
	id <MKAnnotation> annotation;
	int i =0;
	//アウトプットするarray
	NSMutableArray *annotationArray = [[NSMutableArray alloc]initWithCapacity:0];
	//mapView_のannotationsの中から、現在地とキャラクター以外のものをannotationArrayにいれる。
	for(annotation in mapView_.annotations){
		//NSLog(@"%d: %@ (rCount: %d)",i,[annotation title],[annotation retainCount]);//->ここでのrCountも3から6と多いが、正常値のよう(CHARACTER、CurrentLocatinは未検証)。
		//if(![[annotation title]isEqualToString:@"CHARACTER"] && ![[annotation title]isEqualToString:@"Current Location"] && ![[annotation title]isEqualToString:@"WWYRamia"]){
		if([annotation isKindOfClass:[WWYAnnotation class]] && [annotation respondsToSelector:@selector(annotationType)]){//もしannotationがWWYAnnotationクラスかつ、annotationTypeというメソッドを持っていたら
			if([annotation annotationType] == WWYAnnotationType_castle){
				[annotationArray addObject:annotation];
			}
		}
		i++;
	}
	return annotationArray;
}

//30秒待ってロケーションが取得できない場合に、MyLocationGetterから呼ばれる
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

//地図上をタップして、Anotationを追加する関係のメソッド*************************************************
//「地図上をタップして、Anotationを追加するモード」をスタートする
-(void)startAddAnotationWithTap{
	catchTapOnMapView_.isCatchEnable_ = true;
	isAddAnotationWithTapMode_ = true;
}
//「地図上をタップして、Anotationを追加するモード」を終える
-(void)completeAddAnotationWithTap{
	isAddAnotationWithTapMode_ = false;
	nowAddingAnnotation_ = nil;
	catchTapOnMapView_.isCatchEnable_ = false;
}
//「地図上をタップして、Anotationを追加するモード」を途中でキャンセルする
-(void)cancelAddAnotationWithTap{
	//直前にえらんだ場所に建ったAnnotationを消す。
	if(nowAddingAnnotation_)[mapView_ removeAnnotation:nowAddingAnnotation_];
	nowAddingAnnotation_ = nil;
	isAddAnotationWithTapMode_ = false;
	catchTapOnMapView_.isCatchEnable_ = false;
}
//地図上をタップして、Anotationを追加する（外部からも呼ばれる）
-(void)addAnotationWithTapCoordinate:(CLLocationCoordinate2D)coordinate{
	//現在場所を選んでる途中なら、直前にえらんだ場所に建ったAnnotationを消す。
	if(nowAddingAnnotation_)[mapView_ removeAnnotation:nowAddingAnnotation_];
	//Annotation追加
	nowAddingAnnotation_ = [self addAnnotationWithLat:coordinate.latitude Lng:coordinate.longitude 
												title:NSLocalizedString(@"task_area",@"") subtitle:@"" 
									   annotationType:WWYAnnotationType_taskBattleArea selected:YES moved:YES];
}

//CatchTapOnMapViewのDelegateメソッド*****************************************************
//Tap位置取得メソッド
-(void)receiveTapPosition:(CGPoint)point{
	//NSLog(@"hitTest() x=%f y=%f", point.x, point.y);
	
	//図上をタップして、Anotationを追加するモードなら、Anotationを追加する。
	if(isAddAnotationWithTapMode_){
		//CLLocationCoordinate2D coordinate = [mapView_ convertPoint:point toCoordinateFromView:mapView_];
		CLLocationCoordinate2D coordinate = [self convertToCoordinateFromPoint:point];
		[self addAnotationWithTapCoordinate:coordinate];
	}
}

//debugModeメソッド*******************************************************************
//WWYViewControllerからdebugViewの矢印ボタンを押したときに呼ばれる
-(void)moveStartOnDebug:(int)direction{
	//LatLngベースで一定の距離増減するバージョン。
	/*CGPoint debugMoveStep;
	switch (direction) {
		case 0:
			debugMoveStep = CGPointMake(0, 0.001);
			break;
		case 1:
			debugMoveStep = CGPointMake(0.001, 0);
			break;
		case 2:
			debugMoveStep = CGPointMake(0, -0.001);
			break;
		case 3:
			debugMoveStep = CGPointMake(-0.001, 0);
			break;
		default:
			break;
	}
	//CLLocationCoordinate2D currentCoor = [[characterAnnotationArray_ objectAtIndex:0]coordinate];
	CLLocationCoordinate2D currentCoor = currentCLLocation_.coordinate;
	locationForDebug = [[CLLocation alloc]initWithLatitude:currentCoor.latitude+debugMoveStep.y longitude:currentCoor.longitude+debugMoveStep.x];
	[self upDatesCLLocation:locationForDebug];
	*/
	//frameベースで一定の距離を増減するバージョン
	CGPoint nextPoint;
	if(currentCLLocation_){
		//nextPoint = [mapView_ convertCoordinate:currentCLLocation_.coordinate toPointToView:mapView_];
		nextPoint = [self convertToPointFromCoordinate:currentCLLocation_.coordinate];
	}else if(characterAnnotationArray_){
		//nextPoint = [mapView_ convertCoordinate:[[characterAnnotationArray_ objectAtIndex:0]coordinate] toPointToView:mapView_];
		nextPoint = [self convertToPointFromCoordinate:[[characterAnnotationArray_ objectAtIndex:0]coordinate]];
	}else{
		nextPoint = CGPointMake(100, 100);
	}
	CGPoint debugMoveStep;
	 switch (direction) {
	 case 0:
			 nextPoint.y -= 40.0;
	 break;
	 case 1:
			 nextPoint.x += 40.0;
	 break;
	 case 2:
			 nextPoint.y += 40.0;
	 break;
	 case 3:
			 nextPoint.x -= 40.0;
	 break;
	 default:
	 break;
	 }
	//CLLocationCoordinate2D nextCoor = [mapView_ convertPoint:nextPoint toCoordinateFromView:mapView_];
	CLLocationCoordinate2D nextCoor = [self convertToCoordinateFromPoint:nextPoint];
	CLLocation* tmpLocation = [[CLLocation alloc]initWithLatitude:nextCoor.latitude longitude:nextCoor.longitude];
	 
	[self upDatesCLLocation:tmpLocation];
	//なぜか以下のNSLogを書かないと、実機ではCurrentCLLocationがアップデートされない。なんで？？
	//NSLog(@"tmpLocation-latitude:%f longitude:%f",tmpLocation.coordinate.latitude,tmpLocation.coordinate.longitude);
	[tmpLocation autorelease];
}
-(void)moveStopOnDebug{
}


//MKMapViewDelegateメソッド************************************************************************
- (void)mapView:(MKMapView *)myMapView regionWillChangeAnimated:(BOOL)animated{
	currentCenterCoordinate_ = mapView_.centerCoordinate;

}
- (void)mapView:(MKMapView *)myMapView regionDidChangeAnimated:(BOOL)animated{
	
	//ドラッグで移動した距離が一定以上なら、現在地追随モードをoffにする。
	if(!isJustFollowingLocation_ || wWYViewController_.locationButtonMode == WWYLocationButtonMode_HEADING){//現在地追随モードで追随している最中じゃないか、コンパス追随モードならば
		CLLocationCoordinate2D newCenterCoordinate = mapView_.centerCoordinate;
		CGPoint oldPoint = [mapView_ convertCoordinate:currentCenterCoordinate_ toPointToView:mapView_];
		CGPoint newPoint = [mapView_ convertCoordinate:newCenterCoordinate toPointToView:mapView_];
		CGFloat distance = sqrt( pow((oldPoint.x-newPoint.x),2) + pow((oldPoint.y-newPoint.y),2));
		if(distance > 60.0){
			//現在地追随モードをoffに。
			[wWYViewController_ doLocationButtonActionAtMode:WWYLocationButtonMode_OFF];
		}
	}else {
		isJustFollowingLocation_ = NO;
	}
	
	//ルーラでramiaに乗ってて、現在地に戻ってきたら
	if(nowReturningFromRamia_){
		nowReturningFromRamia_ = false;
		[self returnedFromRamia];
	}
	
	/*if(ramiaAnnotation_){
		NSLog(@"[ramia annotation]lat:%f long:%f",ramiaAnnotation_.coordinate.latitude,ramiaAnnotation_.coordinate.longitude);
		[self addAnnotationWithLat:ramiaAnnotation_.coordinate.latitude Lng:ramiaAnnotation_.coordinate.longitude title:@"test" subtitle:@"" moved:NO];
	}*/
}

	//このメソッド使うとannotationの画像はカスタマイズできるが、userLocationの画像まで変わってしまう・・・がなんとか回避。MKMapView内部ではuserlocationもannotationとして扱うため。
- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	MKAnnotationView* annotationView;
	if([annotation.title isEqualToString:@"CHARACTER"]){
		if([annotation isKindOfClass:[CharacterAnnotation class]]){
			annotationView = [annotation characterView_];
			annotationView.canShowCallout = NO;
			return annotationView;
		}
	}else if([annotation.title isEqualToString:@"WWYRamia"]){
		if([annotation isKindOfClass:[CharacterAnnotation class]]){
			annotationView = [annotation characterView_];
			//最初はramiaのCharacterView_は非表示に。アニメーションもSTOPしておく（ここでやるとだめ。MapViewが任意のタイミングでannotationViewを参照するたびに非表示になってしまう為）
			//annotationView.hidden = true;//[annotationView animationStop];
			[annotationView turnUp];
			annotationView.canShowCallout = YES;
			return annotationView;
		}
	}else if([annotation isKindOfClass:[WWYAnnotation class]]){
		if([annotation respondsToSelector:@selector(annotationType)]){
			switch ([annotation annotationType]) {
				case WWYAnnotationType_castle://検索した結果追加されたランドマークのannotationなら
					annotationView = [[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"awazu"]autorelease];
					annotationView.canShowCallout = YES;
					annotationView.image = [UIImage imageNamed:@"castle_a.png"];
					return annotationView;
					break;
				case WWYAnnotationType_taskBattleArea://タスクのバトルエリアなら
					annotationView = [[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"awazu"]autorelease];
					annotationView.canShowCallout = YES;
					annotationView.image = [UIImage imageNamed:@"castle_b.png"];
					annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
					return annotationView;
					break;
				default:
					break;
			}
		}
	//}else if([annotation.title isEqualToString:@"Current Location"]){//userlocationの場合は(titleが「Current Location」となるため判定できる。
	}
	//その他、現在地等なら、以下を実行する。上のif分のどこかではじかれた場合も、デフォルトの処理として以下。
	//MKMapViewデフォルトのannotationViewを使う。
	annotationView = nil;//nilを返すとMKMapViewデフォルトのannotationViewが使われるみたい。
	annotationView.canShowCallout = NO;	
	return annotationView;
}

/*- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
	for(MKAnnotationView* annotationView in views){
		[mapView_ selectAnnotation:annotationView.annotation animated:YES];
	}
}*/

//annotaionのポップアップの横のボタンをタップしたときのメソッド
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	if([view.annotation isKindOfClass:[WWYAnnotation class]] && [view.annotation respondsToSelector:@selector(annotationType)]){
		switch ([view.annotation annotationType]) {
			case WWYAnnotationType_castle://検索した結果追加されたランドマークのannotationなら
				break;
			case WWYAnnotationType_taskBattleArea://タスクのバトルエリアなら
				nowEditingAnnotation_ = view.annotation;
				[wWYViewController_ editTaskWithID:[[view.annotation userInfo]intValue]];
				break;
			default:
				break;
		}
	}
}
//ViewControlerメソッド************************************************************************
- (void)loadView {//初期化メソッドをloadViewに変更
	[super loadView];
}
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}
*/
 
//前回終了時のmapのregionを取得
- (void)getMapRegionAtLastTime {
	
	//前回終了時の地図位置をDBより取得。
	//※前回狩猟時から引き継ぐのは、縮尺とマップタイプのみに変更。
	FMRMQDBSelect* DBSelect= [[FMRMQDBSelect alloc]init];
	NSMutableString*  queryString = [NSMutableString stringWithString:@"SELECT latitude,longitude,latitudeDelta,longitudeDelta,mapType FROM last_time_mapRegion WHERE id=0"];
	FMResultSet* rs = [DBSelect selectFromDBWithQueryString:queryString];
	
	//rsから取り出す。
	while ([rs next]) {
		latitude_atStart_ =[[rs stringForColumn:@"latitude"]floatValue];
		longitude_atStart_ =[[rs stringForColumn:@"longitude"]floatValue];
		latitudeDelta_atStart_ =[[rs stringForColumn:@"latitudeDelta"]floatValue];
		longitudeDelta_atStart_ =[[rs stringForColumn:@"longitudeDelta"]floatValue];
		mapType_atStart_ =[[rs stringForColumn:@"mapType"]intValue];
	}
	[DBSelect release];
	
	last_time_mapRegion_not_exsist_ = false;
	
	//もし値がとれてないか、初回起動時（全て値が999)ならば、デフォルト値（日本列島俯瞰）を設定
	if(!latitude_atStart_ || latitude_atStart_==999) latitude_atStart_ = 36.199795, last_time_mapRegion_not_exsist_ = true;//値がとれなかったらフラグも設定
	if(!longitude_atStart_ || longitude_atStart_==999) longitude_atStart_ = 136.357513;
	if(!latitudeDelta_atStart_ || latitudeDelta_atStart_==999) latitudeDelta_atStart_ = 23.536058;//0.014;
	if(!longitudeDelta_atStart_ || longitudeDelta_atStart_==999) longitudeDelta_atStart_ = 22.236328;//0.013;
	if(!mapType_atStart_ || mapType_atStart_==999) mapType_atStart_ = 0;
	if(last_time_mapRegion_not_exsist_) NSLog(@"last_time_mapRegion_not_exsist_");
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

//その他のメソッド************************************************************************
-(void)logCurrentRegion{
	NSLog(@"lat:%f",mapView_.region.center.latitude);
	NSLog(@"lng:%f",mapView_.region.center.longitude);
	NSLog(@"span.lat:%f",mapView_.region.span.latitudeDelta);
	NSLog(@"span.lng:%f",mapView_.region.span.longitudeDelta);
	//NSLog([[NSLocale currentLocale] localeIdentifier] );
	//if(ramiaAnnotation_) NSLog(@"ramiaAnnotation_ Rcount :%d",[ramiaAnnotation_ retainCount]);
}
-(void)logCurrentLocation{
	NSLog(@"CurrentLocation-latitude:%f longitude:%f",currentCLLocation_.coordinate.latitude,currentCLLocation_.coordinate.longitude);
}
- (void)dealloc {	
	if(nowLocatingImageView_) [nowLocatingImageView_ removeFromSuperview];[nowLocatingImageView_ release];nowLocatingImageView_ = nil;
	if(catchTapOnMapView_) [catchTapOnMapView_ removeFromSuperview]; [catchTapOnMapView_ autorelease];
	if(mapView_) [mapView_ removeFromSuperview]; [mapView_ release];//removeAnnotationsは必要？
	//if(myLocationGetter_) [myLocationGetter_ stopUpdatingLocation];[myLocationGetter_ release];
	if(characterAnnotationArray_) [characterAnnotationArray_ release];
	if(ramiaAnnotation_) [ramiaAnnotation_ close];[ramiaAnnotation_ release];
	if(ramiaDummyView_)	[ramiaDummyView_ removeFromSuperview];[ramiaDummyView_ close];[ramiaDummyView_ release];
	if(tempCharaViewArrayForRamia_){
		for	(CharacterView *cView in tempCharaViewArrayForRamia_){
			[cView removeFromSuperview];[cView close];[cView autorelease];
		}
		[tempCharaViewArrayForRamia_ release];
	}
	
	[super dealloc];
}

@end
