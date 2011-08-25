//
//  MyLocationGetter.m
//  RealMapQuest01
//
//  Created by awaBook on 09/01/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyLocationGetter.h"
#import "WWYViewController.h"

@implementation MyLocationGetter 
@synthesize delegate_;
@synthesize headingAvailable_;

- (void)startUpdates 
{ 
	//初期設定
	locationAvailable_ = NO;
	
    // このオブジェクトがまだLocation Managerを持っていない場合は、 
    // Location Managerを作成する 
	if(nil==locationManager_) {
		locationManager_=[[CLLocationManager alloc]init]; 
		locationManager_.delegate=self; 
		locationManager_.desiredAccuracy=kCLLocationAccuracyKilometer; 
		//移動のしきい値を設定する 
		//locationManager_.distanceFilter=10; //10m
		locationManager_.distanceFilter=kCLDistanceFilterNone; //しきい値なし（高精度）
		[locationManager_ startUpdatingLocation]; 
		
		//120秒待ってロケーションが取得できない場合は、delegate_に通知して、更新をストップするためのタイマー
		[NSTimer scheduledTimerWithTimeInterval:120.0f
										 target:self
									   selector:@selector(checkLocationAvailable:)
									   userInfo:nil
										repeats:NO];
		
		// コンパスが利用できるかどうか 
		headingAvailable_ = locationManager_.headingAvailable;
        
        //現在地取得できない環境でデバッグするために、2秒後に現在地をdelegateにプッシュ。（その後タイマーはautorelease）
        if(IS_TEST && PUSH_DAMMY_LOCATION_AT_TEST){
            [NSTimer scheduledTimerWithTimeInterval:2.0f
                                             target:self
                                           selector:@selector(debugWhenNoLocation:)
                                           userInfo:nil
                                            repeats:NO];
        }
	}
} 
//現在地取得できない環境でデバッグするために、delegateに現在地をプッシュ
-(void)debugWhenNoLocation:(NSTimer*)timer{
    if(IS_TEST && PUSH_DAMMY_LOCATION_AT_TEST){
        [delegate_ upDatesCLLocation:[[CLLocation alloc]initWithLatitude:35.6 longitude:140.1]];
    }
}

// CLLocationManagerDelegateプロトコルのデリゲートメソッド(位置)
- (void)locationManager:(CLLocationManager*)manager 
didUpdateToLocation:(CLLocation*)newLocation 
fromLocation:(CLLocation*)oldLocation 
{ 
	if(!locationAvailable_) locationAvailable_ = YES;
	/**printf("latitude%+.6f,longitude%+.6f\n", 
		   newLocation.coordinate.latitude, 
		   newLocation.coordinate.longitude);*/
	
	// 比較的新しいイベントの場合は、節電のために更新をオフする（今はオフにしてない。仕様がよくわからんのでこの辺は実機を見ながら）
	NSDate* eventDate = newLocation.timestamp; 
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow]; 
	if(abs(howRecent) < 5.0) { 
		//[locationManager stopUpdatingLocation]; //ここでオフ 
	} 
    // それ以外の場合は、このイベントをスキップして次のイベントを処理する 
	[delegate_ upDatesCLLocation:newLocation];
} 
// CLLocationManagerDelegateプロトコルのデリゲートメソッド(コンパス情報取得)
- (void)locationManager:(CLLocationManager *)manager   
	   didUpdateHeading:(CLHeading *)newHeading {  
	[delegate_ upDatesCLHeading:newHeading];
}  

//120秒待ってロケーションが取得できない場合は、delegate_に通知して、更新をストップする
-(void)checkLocationAvailable:(NSTimer*)timer{
	if(!locationAvailable_){
		[self stopUpdatingLocation];
		[delegate_ locationUnavailable];
	}
}
//更新をストップする
-(void)stopUpdatingLocation{
	[locationManager_ stopUpdatingLocation];//このメソッド実行してもretainCountには関係ない。
}

//コンパスの更新を開始する
-(void)startUpdatingHeading{
	// コンパスが利用できるかどうかを判定した上でstartUpdatingHeadingをコール  
	if (headingAvailable_) {  
		[locationManager_ startUpdatingHeading];  
	}  
}
//コンパスの更新をストップする
-(void)stopUpdatingHeading{
	[locationManager_ stopUpdatingHeading];
	if (headingAvailable_) {  
		[delegate_ stopCLHeading];
	}
}

- (void)dealloc {
	NSLog(@"MyLocationGetter----------dealloc!!!");
	if(locationManager_) [locationManager_ stopUpdatingLocation];[locationManager_ autorelease];
	[super dealloc];
}

@end 
