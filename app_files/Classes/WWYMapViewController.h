//
//  WWYMapViewController.h
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class DebugViewController;
@class CharacterView;
@class MyLocationGetter;
@class CharacterAnnotation;
@class ConfigViewController;
@class WWYViewController;
@class WWYHelper_DB;
@class CatchTapOnMapView;
#import "WWYAnnotation.h"

//カスタムSQLite操作用
#import "FMRMQDBSelect.h"
#import "FMRMQDBUpdate.h"
#import "FMResultSet.h"

@interface WWYMapViewController : UIViewController <MKMapViewDelegate> {
	IBOutlet WWYViewController* wWYViewController_;
	MKMapView* mapView_;//MKMapViewはsubclassに拡張して使わない方がいいらしい。ドキュメントに書いてる。
	CGRect mapFrame_;
	UIImageView *nowLocatingImageView_;
	
	CLLocationCoordinate2D currentCenterCoordinate_;
	
	//MyLocationGetter* myLocationGetter_;
	CLLocation* currentCLLocation_;
	
	NSMutableArray* characterAnnotationArray_;
	Boolean doesCharacterFollowCurrentLocation_;//キャラクタが現在地に追随するかどうか
	
	Boolean nowOnRamia_;//ルーラでラーミアに乗ってるときかどうか
	Boolean nowReturningFromRamia_;//ルーラでのラーミアから現在地に帰ってくるときにture
	CharacterAnnotation *ramiaAnnotation_;//ラーミアを表現するCharacterAnnotaion。
	CharacterView *ramiaDummyView_;//乗り込むときのアニメーション時、実機ではannotation経由のramiaView_の描画が遅い場合があるので、このCharacterViewも重ねる。
	NSMutableArray *tempCharaViewArrayForRamia_;//ラーミアアニメーション時の、一時的なCharacterViewを入れるarray
	id <MKAnnotation> anno_destinationOfLoula_;//ルーラのとび先のannotation。オブジェクト生成しないで、annotationを参照するだけにすること。ラーミアアニメーション実装により、インスタンス変数として定義必要になった。
	
	int userlocationUpdate_;
	
	//start時のmapRegion
	CGFloat latitude_atStart_,longitude_atStart_,latitudeDelta_atStart_,longitudeDelta_atStart_;
	int mapType_atStart_;
	Boolean last_time_mapRegion_not_exsist_;//start時のmapRegionがとれなかったときにtrue。このフラグを使って初回起動時的な処理。
	
	//mapView上をTapした座標をとるためのView
	CatchTapOnMapView* catchTapOnMapView_;
	
	//現在「地図上をタップしてAnotationを追加するモードか」どうか
	Boolean isAddAnotationWithTapMode_;
	//地図上をタップして、Anotationを追加しているときのAnnotationの参照
	WWYAnnotation *nowAddingAnnotation_;
	//現在EditしているAnnotation
	WWYAnnotation *nowEditingAnnotation_;

}
- (id)initWithMapFrame:(CGRect)frame parentViewController:(WWYViewController*)pViewController;
-(void)setCenterAtCurrentLocation;
-(void)changeMapType:(int)type;
-(void)goAnnotation:(id<MKAnnotation>)annotation;
-(void)moveStartOnDebug:(int)direction;
-(void)moveStopOnDebug;
-(void)logCurrentRegion;
-(void)makeRootDataTo:(CLLocationCoordinate2D)_newCoordinate on:(CharacterAnnotation*)_characterAnnotation;
-(void)upDatesCLLocation:(CLLocation*)newLocation;//MyLocaitonGetterから新しいCLLocationが来たときに呼ばれる。
-(CGPoint)convertToPointFromLocation:(CLLocation*)location;//characterViewから、自分の位置を計算するために呼ばれる
-(CLLocationCoordinate2D)convertToCoordinateFromPoint:(CGPoint)point;//他クラスから位置を計算するために呼ばれる
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle moveYes:(BOOL)moveYes;//annotationをプラスするために呼ばれる。（WWYViewControllerから等。旧互換のためのメソッド。）
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle annotationType:(int)annotationType userInfo:(id)userInfo moveYes:(BOOL)moveYes;//annotationを追加するために呼ばれる（WWYViewControllerから等。userInfoつき。）
-(WWYAnnotation*)addAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude title:(NSString*)title subtitle:(NSString*)subtitle annotationType:(int)annotationType moveYes:(BOOL)moveYes;//annotationをプラスするために呼ばれる。（WWYViewControllerから等）
-(void)locationUnavailable;//30秒待ってロケーションが取得できない場合に、MyLocationGetterから呼ばれる
-(NSArray*)getPureAnnotations;//現在地とキャラクター以外のannotations配列を取得する。
- (CLLocation *)getNowLocationForAdMob;//AdMob用に現在地を返すメソッド。WWYAdControllerから呼ばれる
- (void)getMapRegionAtLastTime;//前回終了時のmapのregionを取得。
-(void)makeMapViewWithFrame:(CGRect)frame region:(MKCoordinateRegion)region;//mapView_を生成、表示
-(void)startAddAnotationWithTap;//「地図上をタップして、Anotationを追加するモード」をスタートする
-(void)completeAddAnotationWithTap;//「地図上をタップして、Anotationを追加するモード」を終える
-(void)cancelAddAnotationWithTap;//「地図上をタップして、Anotationを追加するモード」を途中でキャンセルする
-(void)addAnotationWithTapCoordinate:(CLLocationCoordinate2D)coordinate;//地図上をタップして、Anotationを追加する（外部からも呼ばれる）
-(void)receiveTapPosition:(CGPoint)point;//Tap位置取得メソッド（CatchTapOnMapViewのDelegateメソッド）

@property (readonly,assign) MKMapView* mapView_;
@property (readonly) NSMutableArray* characterAnnotationArray_;
@property (readonly) CLLocation* currentCLLocation_;
@property Boolean nowOnRamia_;
@property Boolean isAddAnotationWithTapMode_;
@property (readonly,assign) WWYAnnotation* nowAddingAnnotation_;
@property (assign) WWYAnnotation* nowEditingAnnotation_;
@end

