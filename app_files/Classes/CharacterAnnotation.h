//
//  CharacterAnnotation.h
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WWYMapViewController;
@class CharacterView;

@interface CharacterAnnotation : CLLocation <MKAnnotation> {
	CharacterView *characterView_;
	
	//<MKAnnotation>プロトコル
	NSMutableString* _title;
	NSMutableString* _subtitle;
	CLLocationCoordinate2D coordinate;
	
	NSTimer* baseTimer;
	int Id;//mapView等から識別するためのID。
	int charaType;//キャラクターのタイプを決める。DBの主キーとひも付ける。
	WWYMapViewController* deleg;
	
	//道筋を格納する配列
	NSMutableArray* rootArray;
	//後ろの人へ道筋を渡す前に格納しておく配列
	NSMutableArray* rootArray_buffer;
	//前の人(nillなら自分が最前列)
	CharacterAnnotation* prevCharacter;
	//後ろの人(nillなら自分が最後尾)
	CharacterAnnotation* nextCharacter;
	//自分の大きさ（半径）、UIVeiw.frameベース
	CGFloat mySize;
	//同じ方向への移動の連続を格納する変数
	int up_sequence,down_sequence,right_sequence,left_sequence;
	//現在の向き
	int currentDirection;
	//前のキャラと重なっている間はYESになるフラグ
	bool overlapWithPrevCharacter;
	//前のキャラと重なってたり、移動距離が小さかったりしても強制的に移動させるためのフラグ。mustMove_enable等で主に外部から設定。
	bool mustMove;
	//マストな移動が終わってからmustMoveをfalseにするかどうかのフラグ
	bool mustMove_disable_flag;
	
}
-(id) initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude
				 title:(NSString*)title subtitle:(NSString*)subtitle
				withCharaType:(int)type withID:(int)myID;
- (NSString *)title;
- (NSString *)subtitle;
-(void)setMyDeleg:(WWYMapViewController*)myDeleg;//このメソッドでdelegateを設定しないと向きの制御ができないので注意。本来ならinitWith〜に入れるべきなので余裕あったら修正。
-(void) pushRootArray:(CLLocation*)location;
-(void)clearRootData;
-(void)close;
-(void)mustMove_enable;//mustMoveをtrueにする
-(void)mustMove_disable;//マストな移動が終わってからmustMoveをfalseにする


@property CLLocationCoordinate2D coordinate;//スーパークラスのCLLocationで定義されてるのでここでは不要だったが、スーパークラスではreadonlyみたいなので一応このように実装しておく。これでマップ内での位置を変更できる。
@property int Id;
@property int charaType;
@property int currentDirection;
@property bool overlapWithPrevCharacter;
@property (assign) NSMutableArray* rootArray;
@property (assign) CharacterAnnotation* prevCharacter;
@property (assign) CharacterAnnotation* nextCharacter;
@property (assign) WWYMapViewController* deleg;
@property (readonly,assign) CharacterView *characterView_;

@end
