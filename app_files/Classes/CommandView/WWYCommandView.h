//
//  WWYCommandView.h
//  Version 2.0
//
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WWYCommandViewDelegate.h"//プロトコル定義ファイル読み込み。
#import "Define.h"
@class WWYCommandColumnView;
@class WWYCommandArrowView;
@class WWYCommandFrameView;

@interface WWYCommandView : UIView {
	id target_;//コマンドの送り先オブジェクト
	
	int commandViewId;//delegateからみてどのコマンドViewかを識別するId。（旧CommandColumnViewのcommandTypeと同じ使い方を想定）
	NSMutableArray* commandColumnArray;//各CommandColumnViewを格納。
	id <WWYCommandViewDelegate> delegate;//プロトコルメソッドを受けるインスタンス
	int spacing;//各コマンドテキストの上下の間隔。
	int yTop;//一番上のカラムのY位置
	int selecting;//タッチにて選択中のコマンド。0から始まる番号で管理。
	Boolean touchEnable;//touchを受け付けたときに処理をするか。
	int maxColumnAtOnce ;//一度に表示する最大のカラム数
	int displayColumnNum;//実際に表示されるカラム数。
	int startColumn ;//ページ送りにおいて、表示し始めるカラム番号。
	WWYCommandArrowView* arrowButton;//次のページを表示させるボタン
	float arrowSize;//arrowButtonのサイズ。今のところ外からは使わない。
	float arrowPadding;//arrowButtonのpadding。今のところ外からは使わない。
	CGFloat arrowButtonMargin;//arrowButtonが上に出っ張る分の値。出っ張る分、枠やテキストの表示位置を調整するために内部で使用。
	WWYCommandFrameView *frameView_;//枠。
	UILabel* titleLabel;
	int brinkingColumnNumber;//明滅するCommandColumnVewのcommandColumnArrayにおけるインデックスを格納。
	
	SystemSoundID clickA; //sound
	//SystemSoundID clickB; //sound
	
}

//initメソッド1（今後こちらをメインに）
- (id)initWithFrame:(CGRect)frame target:(id)target maxColumnAtOnce:(int)maxColumn;
//initメソッド2（旧バージョン互換。必要ないなら消す）
- (id)initWithFrame:(CGRect)frame withCommandTextArray:(NSArray*)array withMaxColumn:(int)myMaxColumn withDelegate:(id <WWYCommandViewDelegate>)deleg withCommandViewId:(int)cmdViewId;
-(void)addCommand:(NSString*)command action:(SEL)selector userInfo:(id)userInfo;//コマンドのテキストと、実行するメソッド、引数の追加
-(void)insertCommand:(NSString*)command action:(SEL)selector userInfo:(id)userInfo AtIndex:(int)index;//コマンドのテキストと、実行するメソッドをindex指定して挿入
-(void)removeCommandAtIndex:(int)index;//コマンドを消去する。indexで何番目か指定。
-(void)setIDForColumnsFromNSNumberArray:(NSArray*)myIDArray;//IDを各コマンドカラムビューにいれるためのメソッド
//-(void)cancel;//このコマンドViewをキャンセルするメソッド。
-(void)setTitle:(NSString*)title withWidth:(CGFloat)width withHeight:(CGFloat)heightOrZero;//タイトルを設定して、表示するメソッド。タイトルを表示する領域の幅と高さも指定。高さは0ならば自動設定。
-(void)resetToDefault;//デフォルトの状態にするメソッド。（ページ送りを初期値にするなど。）外部から呼ぶ。
-(void)columnViewArrowStartBlinking:(int)columnViewNumber;//columnViewNumber(0から始まる)個めのcommandColumnViewのarrowボタンを点滅させる。
-(void)columnViewArrowStopBlinking:(int)columnViewNumber;//columnViewNumberr(0から始まる)個めのcommandColumnViewのarrowボタンの点滅をストップさせる。
-(void)adjustHeight;//高さの自動設定。
-(void)changeFrame:(CGRect)newFrame;//位置や大きさを変更する。
-(int)getDisplayColumnNum;//現在表示すべきカラム数を得る。

@property Boolean touchEnable;
@property int commandViewId;
@property (readonly) NSMutableArray* commandColumnArray;
@end
