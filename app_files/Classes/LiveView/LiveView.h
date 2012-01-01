//
//  LiveView.h
//  RMQuest2
//
//  Created by awaBook on 09/02/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LiveViewDelegate.h"//プロトコル定義ファイル
#import "Define.h"

@class CursorButtonView;

//テキストが枠いっぱいになったとき次のテキストに進む方法の定数宣言。
typedef enum {WWYLiveViewOverflowMode_cursorButton,	//カーソルボタンで次のテキストに送る方法
	WWYLiveViewOverflowMode_delegateAction,	//delegateからのアクションで次のテキストに送る方法
	WWYLiveViewOverflowMode_noAction} WWYLiveViewOverflowMode;	//ユーザからのアクションなしで自動的に次のテキストに送る方法

//表示する言語の設定。1行の表示文字数に影響。デフォルトではユーザーの言語環境から自動設定。
typedef enum {
    WWYLiveViewLanguageMode_ja,	
	WWYLiveViewLanguageMode_en
    } WWYLiveViewLanguageMode;

@interface LiveView : UIView {
	
	id <LiveViewDelegate> delegate;
	//****************************************************************************
	//当初は文章表示終了後にdelegateにメソッドを送る形で、終了後のアクションを実行していたが、
	//WWYCommandViewと同じく、delegateのメソッド管理が大変なので、target/selector形式に改変した。
	//一応当初の方法との互換性はまだとってある。
	//****************************************************************************
	
	float actionDelay_;//文章が終わったときに、アクションを実行するまでの秒数
	
	id targetObj_;//文章が終わったときに、メソッドが送られるオブジェクト
	//****************************************************************************
	//☆☆☆☆☆☆注意☆☆☆☆☆☆
	//targetObj_は参照。retain、releaseでメモリ管理しようとしたがなぜかうまく行かなかった。
	//文章表示終了後のアクションが実行されるタイミングでtargetObj_がなくなってないようにすること。
	//****************************************************************************
	
	SEL selector_;//文章が終わったときに、実行されるメソッド
	id userInfo_;//文章が終わったときに、引数としてメソッドに渡されるオブジェクト
	
	//最大同時表示行数
	int maxColumn;
	
	//一列の最大同時表示文字数（おおきさから自動設定される）
	int maxWords;
	
	//描画するテキスト
	NSMutableString* text;
	
	//描画するテキストのID。描画終了をdelegに伝えるときに使う。
	int textID;
	
	//テキスト枠を5つ格納する配列
	NSMutableArray* textFieldArray;
	
	//描画中のテキスト枠
	int current_textField;
	
	//テキストが枠いっぱいになったとき、どの方法で次のテキストに進むか。プロパティにして外部から設定する。デフォルトは三角ボタンでの方法。
	WWYLiveViewOverflowMode overflowMode;
	
    //表示する言語。1行の表示文字数に影響。デフォルトではユーザーの言語環境から自動設定。
    WWYLiveViewLanguageMode language_;
	
	//スクロール促すしるし。▼。ボタンにもなる。
	CursorButtonView* moreTextButt;
	
	//三角ボタンがタッチ可能かどうか
	BOOL buttonEnable;
	
	//NSArrayでテキスト内容と順番を指定し、ユーザーに三角ボタンを押させるなどしてから次のテキストを描画するという形式での表示中かどうかを格納する変数。
	BOOL seqTextMode;
	//上記seqTextModeのときのbuttonEnable。
	BOOL seqTextMode_buttonEnable;
	//上記seqTextModeのとき、テキストの順番を格納する変数。
	int seqText_i;
	//上記seqTextModeのとき、描画するテキストが順番通りに格納された配列。引数で指定されたものをコピーして保持。
	NSMutableArray* seqTextArray;
	
	//タイマー
	NSTimer* timer;
	int ti;//タイマー用i。描画中の文字が何番目かを表す。
	int tj;//タイマー用i。描画中の文字が行の中で何番目かを表す
	int tk;//タイマー用i。textの最初から使ったテキストフィールドの数を表す。
	int hajime;///タイマー用。行のはじめが何番目の文字かを格納する変数。
	
	SystemSoundID clickA; //sound
	SystemSoundID clickC; //sound
}
- (id)initWithFrame:(CGRect)frame withDelegate:(id<LiveViewDelegate>)deleg;
- (id)initWithFrame:(CGRect)frame withDelegate:(id<LiveViewDelegate>)deleg withMaxColumn:(int)maxcolumn;//maxColumn指定してのinitメソッド
-(void)setTextAndGo:(NSString*)txt;//テキスト内容をリセットし、再描画を開始するメソッド。主に外部から呼ぶ。
-(void)setTextAndGo:(NSString*)txt withTextID:(int)txtID;//上のメソッドに、textIDの設定も追加したメソッド。
-(void)setTextAndGo:(NSString*)txt actionAtTextFinished:(SEL)selector userInfo:(id)userInfo target:(id)target;//上の上のメソッドに、表示終了後実行するメソッドの設定も追加したメソッド。
-(void)setSeqTextAndGo:(NSArray*)txtArray;//一度に全て表示しないで、NSArrayでテキスト内容と順番を指定し、ユーザーに三角ボタンを押させるなどしてから次のテキストを描画するという形式での表示を設定、開始するメソッド。（要素が一つの配列を引数にした場合は、setTextAndGoと同じ動作をする。）
-(void)setSeqTextAndGo:(NSArray*)txtArray withTextID:(int)txtID;//上のメソッドに、textIDの設定も追加したメソッド。
-(void)makeTimer;
-(void)onTextFieldOver;
//-(void)moreText;
-(void)moveUpTexFields;
-(void)goNextText;//overflowしていた次のテキストを描画する。
-(void)doActionWhenTextEnded;//テキストを最後まで描画し終わったときのアクションを実行。
- (void)close;//メモリ解放される準備をする。タイマー動いてたらタイマー止めたり。

@property (retain) NSMutableString* text;
@property (readonly)CursorButtonView* moreTextButt;
@property (readonly) BOOL buttonEnable;
@property WWYLiveViewOverflowMode overflowMode;
@property WWYLiveViewLanguageMode language;
@property float actionDelay;

@end
