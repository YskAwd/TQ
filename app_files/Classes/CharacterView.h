//
//  CharacterView.h
//  WWY
//
//  Created by awaBook on 09/07/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//カスタムSQLite操作用
#import "FMRMQDBSelect.h"
#import "FMRMQDBUpdate.h"
#import "FMResultSet.h"

//このクラスのインスタンスを破棄する際には、"close"メソッドを明示的に呼ぶこと。
//内部タイマーによるretainCountなどをうまいことやってくれる。
//closeメソッド呼ばないと、retainCountが0にならず、解放できない。

@interface CharacterView : MKAnnotationView {
	NSMutableArray* characterImageArrays;
	NSMutableArray* characterImageArrayFront;
	NSMutableArray* characterImageArrayRight;
	NSMutableArray* characterImageArrayLeft;
	NSMutableArray* characterImageArrayBack;
	NSTimer* baseTimer;	
	
	//同じ方向への移動の連続を格納する変数
	int up_sequence,down_sequence,right_sequence,left_sequence;
	
	//UIImageをパラパラマンガ的に変化させるための変数
	int imageSeqStep;
	
	//現在の向き
	int currentDirection;
	
	
}
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier withCharaType:(int)type;
-(void) turnUp;
-(void) turnRight;
-(void) turnLeft;
-(void) turnDown;
-(void)close;//このクラスのインスタンスを破棄する際には、"close"メソッドを明示的に呼ぶこと。呼ばないと、retainCountが0にならず、解放できない。
-(void)reassignCharacter:(int)charaType;//charaTypeをキーにキャラを再設定するメソッド
-(void)animationStart;
-(void)animationStop;

@end
