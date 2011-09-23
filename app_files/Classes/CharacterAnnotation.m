//
//  CharacterAnnotation.m
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterAnnotation.h"
#import "WWYMapViewController.h"
#import "CharacterView.h"

@implementation CharacterAnnotation
@synthesize Id;
@synthesize charaType;
@synthesize coordinate;
@synthesize deleg;
@synthesize prevCharacter;
@synthesize nextCharacter;
@synthesize currentDirection;
@synthesize overlapWithPrevCharacter;
@synthesize characterView_;

-(id) initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude
				 title:(NSString*)title subtitle:(NSString*)subtitle
				withCharaType:(int)type withID:(int)myID {
	if([super initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude]) {
		if(title == nil) title = @"";
		_title = [[NSMutableString alloc]initWithString:title];//NSLog(@"[title retainCount]%d",[title retainCount]);
		if(subtitle == nil) subtitle = @"";
		_subtitle = [[NSMutableString alloc]initWithString:subtitle];
		coordinate.latitude=latitude;
		coordinate.longitude=longtitude;
		
		Id=myID;
		charaType = type;
		rootArray = [[NSMutableArray alloc]init];
		rootArray_buffer = [[NSMutableArray alloc]init];
		mySize = 40.0;
		currentDirection = 2;
		overlapWithPrevCharacter = FALSE;
		mustMove = false;
		mustMove_disable_flag = false;
		//timer 新しいLocationがないときは、止めること！！！
		[self makeBaseTimer];
		
		//characterViewを作る（生成のみ。mapViewのdelegateのviewForAnnotaionで呼び出されて使用される）
		characterView_ = [[CharacterView alloc]initWithAnnotation:self reuseIdentifier:_title withCharaType:charaType];
		
	}
	return self;
}

- (NSString *)title{
	return _title;
}
- (NSString *)subtitle{
	return _subtitle;
}

-(void)makeBaseTimer{
	CGFloat interval;
	if (Id == 0) {
		interval = 3.0f/150.0f;//先頭のキャラだけ動きを速くしてみる
	}else if(Id == 100){
		interval = 3.0f/300.0f;//ラーミアはさらに速くしてみる。
	}else {
		interval = 6.0f/150.0f;//先頭以外のキャラの速度
	}
	if(!baseTimer){
		baseTimer = [NSTimer scheduledTimerWithTimeInterval:interval	//(6.0f)/30.0f
													 target:self//これで自動的にretainCountが1増えている。
												   selector:@selector(baseTimerLoop:)
												   userInfo:nil
													repeats:YES];
	}
}

-(void) pushRootArray:(CLLocation*)location{
	[rootArray addObject:[[CLLocation alloc]initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude]];
	//NSLog(@"TST ID%d:%d:",Id,[location retainCount]);
}

-(void) baseTimerLoop:(NSTimer*)timer{
	CGPoint newPoint;
	CGPoint oldPoint;
	if([rootArray count] >0 ) {
		//CLLocation* newLocation = [[CLLocation alloc]initWithLatitude:[[rootArray objectAtIndex:0]coordinate].latitude longitude:[[rootArray objectAtIndex:0]coordinate].longitude];
		
		//なんと直接(MKMapView*)mapViewにアクセスしてlocationからPointを得ようとしたが何やってもダメだった！バグかと思われ。
		//mapViewのViewControllerであり、MKMapDelegateプロトコルのdelegateである(WWYMapViewController*)deleg経由でアクセス。
		
		newPoint = [deleg convertToPointFromLocation:[rootArray objectAtIndex:0]];
		oldPoint = [deleg convertToPointFromLocation:[rootArray_buffer lastObject]];//こちらは向きの制御用
		
		//向きの制御
		if([rootArray_buffer count] >0){
			CLLocation* oldLocation = [rootArray_buffer lastObject];
			CLLocation* newLocation = [rootArray objectAtIndex:0];
			
			if(newLocation.coordinate.latitude < oldLocation.coordinate.latitude){
				up_sequence = 0, down_sequence += 1, right_sequence = 0, left_sequence = 0;
				//向きを変える条件を、とりあえずとってみる(ViewControllerの方で、新ルートが40ピクセル以上開かないとルートをプッシュしないようにしたので)
				//if(fabs(newPoint.y-oldPoint.y) > 3.0 || down_sequence >= 2) {//MapView上の移動位置が5ピクセル以上、もしくは同じ向きへの移動が3回以上続いたなら向きを変える。斜めに現在地が移動したとき、キャラクターが細かくジグザグ向きを変えるのを防ぐため。
					//[self turnDown];
					currentDirection = 2;
					[[deleg.mapView_ viewForAnnotation:self]turnDown];
				//}
			} else if(newLocation.coordinate.latitude > oldLocation.coordinate.latitude){
				up_sequence += 1, down_sequence = 0, right_sequence = 0, left_sequence = 0;
				//if(fabs(newPoint.y-oldPoint.y) > 3.0 || up_sequence >= 2) {
					//[self turnUp];
					currentDirection = 0;
					[[deleg.mapView_ viewForAnnotation:self]turnUp];
				//}
			} else if(newLocation.coordinate.longitude > oldLocation.coordinate.longitude){
				up_sequence = 0, down_sequence = 0, right_sequence += 1, left_sequence = 0;
				//if(fabs(newPoint.x-oldPoint.x) > 3.0 || right_sequence >= 2) {
					//[self turnRight];
					currentDirection = 1;
					[[deleg.mapView_ viewForAnnotation:self]turnRight];
				//}
			}else if(newLocation.coordinate.longitude < oldLocation.coordinate.longitude){
				up_sequence = 0, down_sequence = 0, right_sequence = 0, left_sequence += 1;
				//if(fabs(newPoint.x-oldPoint.x) > 3.0 || left_sequence >= 2) {
					//[self turnLeft];
					currentDirection = 3;
					[[deleg.mapView_ viewForAnnotation:self]turnLeft];
				//}
			}
		}
		
		
		//前のキャラとの距離を条件に移動
		CGPoint prevCharaPoint = [deleg.mapView_ convertCoordinate:prevCharacter.coordinate toPointToView:deleg.mapView_];
		//CGPoint prevCharaPoint = [deleg convertToPointFromCoordinate:prevCharacter.coordinate];
		CGFloat now_distance = sqrt(pow(prevCharaPoint.x-oldPoint.x, 2) + pow(prevCharaPoint.y-oldPoint.y, 2));
		CGFloat new_distance = sqrt(pow(prevCharaPoint.x-newPoint.x, 2) + pow(prevCharaPoint.y-newPoint.y, 2));

		if(new_distance > mySize*0.9 || overlapWithPrevCharacter || mustMove){
			[self setCoordinate:[[rootArray objectAtIndex:0]coordinate]];
			//移動し終わった位置情報はrootArray_bufferにpushして、rootArrayから削除。
			if([rootArray count] >1 ) {//現在地がいつでも要素[0]に入っててほしいので、rootArrayを空っぽにはしない。
				[rootArray_buffer addObject:[rootArray objectAtIndex:0]];
				[rootArray removeObjectAtIndex:0];
			}
		}
		if(!overlapWithPrevCharacter && now_distance < mySize*0.9){
			overlapWithPrevCharacter = TRUE;
		}
		if(overlapWithPrevCharacter && new_distance > mySize*0.9){
			overlapWithPrevCharacter = FALSE;
		}
		if(mustMove_disable_flag){
			mustMove = false;
			mustMove_disable_flag = false;
		}
	}
	if([rootArray_buffer count] >0 ) {
		//次のキャラとの距離を条件に次のキャラにルートを渡す。
		CGPoint nextCharaNewRoot = [deleg convertToPointFromLocation:[rootArray_buffer objectAtIndex:0]];
		CGFloat distance = sqrt(pow(nextCharaNewRoot.x-newPoint.x, 2) + pow(nextCharaNewRoot.y-newPoint.y, 2));
		if(distance > mySize*0.9 && [rootArray_buffer count] >1){
			[[rootArray_buffer objectAtIndex:0]release];
			[nextCharacter pushRootArray:[rootArray_buffer objectAtIndex:0]];
			[rootArray_buffer removeObjectAtIndex:0];
		}
		
	}
}


//今持っている道筋を消す。全消し。//一つ残らず消して大丈夫かな？でも一つのこしてみたら、カクカク戻りながら進んでしまう。
-(void)clearRootData{
	for (CLLocation* loc in rootArray){
		[loc release];
	}
	[rootArray removeAllObjects];
	for (CLLocation* loc in rootArray_buffer){
		[loc release];
	}
	[rootArray_buffer removeAllObjects];
}

-(void)setMyDeleg:(WWYMapViewController*)myDeleg{
	deleg = myDeleg;
}

//mustMoveをtrueにする
-(void)mustMove_enable{
	mustMove = true;
}
//マストな移動が終わってからmustMoveをfalseにする
-(void)mustMove_disable{
	mustMove_disable_flag = true;
}

-(void)close{
	//timerを止めて無効に。//自動的にretainCountが1減る。
	if(baseTimer) [baseTimer invalidate]; baseTimer=nil;
}

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(_title)[_title release];
	if(_subtitle)[_subtitle release];
	[self clearRootData];
	if(rootArray) [rootArray release];
	if(rootArray_buffer) [rootArray_buffer release];
	if(characterView_) [characterView_ removeFromSuperview];[characterView_ close];[characterView_ autorelease];
	[super dealloc];
}


@end
