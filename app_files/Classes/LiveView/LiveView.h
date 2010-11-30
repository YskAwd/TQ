//
//  LiveView.h
//  RMQuest2
//
//  Created by awaBook on 09/02/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveViewDelegate.h"//プロトコル定義ファイル
@class CursorButtonView;

@interface LiveView : UIView {
	
	id <LiveViewDelegate> delegate;
	
	//最大同時表示行数
	int maxColumn;
	
	//描画するテキスト
	NSMutableString* text;
	
	//描画するテキストのID。描画終了をdelegに伝えるときに使う。
	int textID;
	
	//テキスト枠を5つ格納する配列
	NSMutableArray* textFieldArray;
	
	//描画中のテキスト枠
	int current_textField;
	
	//フォント、カラー
	UIFont* fnt;
	UIColor* color_wh;
	UIColor* color_bl;
	
	BOOL buttonEnable;
	
	//ボタンというかスクロール促すしるし。
	CursorButtonView* moreTextButt;
	
	//順番を指定し、ユーザーに三角ボタンを押させてから次のテキストを描画するという形式での表示中かどうかを格納する変数。
	BOOL seqTextMode;
	//上記seqTextModeのときのbuttonEnable。
	BOOL seqTextMode_buttonEnable;
	//上記seqTextModeのとき、テキストの順番を格納する変数。
	int seqText_i;
	//上記seqTextModeのとき、描画するテキストが順番通りに格納された配列。引数で指定されたものをコピーして保持。
	NSArray* seqTextArray;
	
	//タイマー
	NSTimer* timer;
	int ti;//タイマー用i。描画中の文字が何番目かを表す。
	int tj;//タイマー用i。描画中の文字が行の中で何番目かを表す
	int tk;//タイマー用i。textの最初から使ったテキストフィールドの数を表す。
	int hajime;///タイマー用。行のはじめが何番目の文字かを格納する変数。
}
//- (id)initWithFrame:(CGRect)frame text:(NSMutableString*)txt;
-(void)makeTimer;
-(void)onTextFieldOver;
//-(void)moreText;
-(void)moveUpTexFields;
//-(void)setTextAndGo:(NSMutableString*)text;

@property (retain) NSMutableString* text;
@property (readonly)CursorButtonView* moreTextButt;
@property (readonly) BOOL buttonEnable;

@end
