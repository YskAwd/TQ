//
//  WWYAnnotation.h
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Define.h"

//annotationのタイプの型宣言。
typedef enum {
    WWYAnnotationType_normal,
    WWYAnnotationType_userLocation,
    WWYAnnotationType_character,
    WWYAnnotationType_castle,
    WWYAnnotationType_taskBattleArea,
    WWYAnnotationType_taskBattleArea_won,
    WWYAnnotationType_taskBattleArea_lost
} WWYAnnotationType ;

@interface WWYAnnotation : CLLocation <MKAnnotation> {
	NSMutableString* _title;
	NSMutableString* _subtitle;
	CLLocationCoordinate2D coordinate;
	
	//annotationのタイプ
	WWYAnnotationType annotationType_;
	
	id userInfo_;//必要ならばこれに情報を入れる。（annotationType_がWWYAnnotationType_taskBattleAreaの場合は、タスクIDのNSNumberを入れる）
}
-(id) initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longtitude
				 title:(NSString*)title subtitle:(NSString*)subtitle;
/*- (NSString *)title;
- (NSString *)subtitle;*/
@property (retain) NSString* title;
@property (retain) NSString* subtitle;
@property CLLocationCoordinate2D coordinate;//スーパークラスのCLLocationで定義されてるのでここでは不要だったが、スーパークラスではreadonlyみたいなので一応このように実装しておく。これでマップ内での位置を変更できる。
@property WWYAnnotationType annotationType;
@property (retain) id userInfo;
@end
