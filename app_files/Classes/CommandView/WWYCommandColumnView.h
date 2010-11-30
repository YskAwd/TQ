//
//  WWYCommandColumnView.h
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWYCommandViewDelegate.h" //プロトコル定義ファイル読み込み。
@class WWYCommandView;
@class WWYCommandArrowView;

@interface WWYCommandColumnView : UIView {
	id targetObj_;//選択されたときにメソッドが送られるオブジェクト
	SEL selector_;//選択されたときに実行されるメソッド
	id userInfo_;//選択されたときに引数としてメソッドに渡されるオブジェクト
	
	NSMutableString* text; 
	id <WWYCommandViewDelegate> delegate;
	WWYCommandArrowView* arrow;
	int Id;//item等の場合用に、DBにおけるIDを格納する
	int columnNo;//CommandViewの中の何番目の項目かを格納。playerDBかたカンマ区切りitemを消すとき等に使う。
	//int commandType;//戦闘中のたたかうなどのとき0、戦闘中のやくそう等どうぐをタップしたとき1、・・・
	CGSize mySize; //文字を書いたときにかえってくるCGSizeを入れる。
	WWYCommandView* commandView;//親のCommandView
//	bool selected;//今このコマンドが選ばれている（ArowViewが表示されている）ならばtrue。
}
//initメソッド1
- (id)initWithFrame:(CGRect)frame text:(NSString*)commandText 
			 target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo;
//initメソッド2
- (id)initWithFrame:(CGRect)frame withText:(NSString*)commandText 
	   withDelegate:(id <WWYCommandViewDelegate>)deleg withCommandView:(WWYCommandView*)cmdView;
-(void)initialize;//基本初期化処理（内部で使用）
-(void)enterCommand;
-(void)showArrow;
-(void)hideArrow;
-(void)arrowStartBlinking;//arrowボタン明滅スタート
-(void)arrowStopBlinking;//arrowボタン明滅ストップ
	
@property (readonly) NSMutableString* text; 
@property int Id;
@property int columnNo;
@property CGSize mySize;
@property (assign) id <WWYCommandViewDelegate> delegate;
@end
