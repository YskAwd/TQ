//
//  LiveView.m
//  RMQuest2
//
//  Created by awaBook on 09/02/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LiveView.h"
#import "CursorButtonView.h"


@implementation LiveView
@synthesize text;
@synthesize moreTextButt;
@synthesize buttonEnable;
@synthesize overflowMode;
@synthesize actionDelay = actionDelay_;

- (id)initWithFrame:(CGRect)frame withDelegate:(id<LiveViewDelegate>)deleg withMaxColumn:(int)maxcolumn{
	//最大同時表示行数
	maxColumn = maxcolumn;
	CGRect _frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, maxColumn*35); 
    if (self = [super initWithFrame:_frame]) {
        // Initialization code
		delegate = deleg;
		textID = nil;
		current_textField=0;
		
		//フォント、カラー
		UIFont* fnt = [UIFont systemFontOfSize:16.0f];
		UIColor* color_wh=[UIColor whiteColor];
		//color_bl=[UIColor blackColor];
		UIColor* color_bl=[UIColor colorWithWhite:0 alpha:0];
		
		buttonEnable=FALSE;
		
		//moreTextButt=[[CursorButtonView alloc]initWithFrame:CGRectMake(180, 90, 20, 20)];
		moreTextButt=[[CursorButtonView alloc]initWithFrame:CGRectMake(_frame.size.width/2-12, maxColumn*35-27, 25, 10)];
		
		//テキストフィールドの幅
		float textFieldWidth = _frame.size.width-20;
		
		//一列の最大文字数を計算
		//ユーザの言語を判定
		NSArray *languages = [NSLocale preferredLanguages];
		NSString *currentLanguage = [languages objectAtIndex:0];
		int k;//係数
		if([currentLanguage isEqualToString:@"ja"]){//ユーザの言語環境が日本語なら
			k=17;
		}else{//日本語以外なら（アルファベットは文字数多く表示できる）
			k=9;
		}
		//一列の最大文字数（小数点以下切り上げ）
		maxWords = (int)textFieldWidth/k-1;	//NSLog(@"maxWords: %d",maxWords);
		
		//テキストが枠いっぱいになったとき、次のテキストに進む方法。デフォルトは三角ボタンで。
		overflowMode = WWYLiveViewOverflowMode_cursorButton;

		//テキストフィールドとそれを入れるArrayを作成
		textFieldArray=[[NSMutableArray alloc]initWithObjects:[[UITextView alloc]initWithFrame:CGRectMake(20, 10, textFieldWidth, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 30, textFieldWidth, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 50, textFieldWidth, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 70, textFieldWidth, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 90, textFieldWidth, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 110, textFieldWidth, 30)],nil];
		
		for(int i=0;i<[textFieldArray count];i++){
			[[textFieldArray objectAtIndex:i]setFont:fnt];
			[[textFieldArray objectAtIndex:i]setEditable:FALSE];
			[[textFieldArray objectAtIndex:i]setUserInteractionEnabled:FALSE];
			[[textFieldArray objectAtIndex:i]setBackgroundColor:color_bl];
			[[textFieldArray objectAtIndex:i]setTextColor:color_wh];
			[self addSubview:[textFieldArray objectAtIndex:i]];
		}
		[self addSubview:moreTextButt];
		moreTextButt.hidden=YES; [moreTextButt stopBlinking];
		
		//sound
		NSString* soundPathA = [[NSBundle mainBundle]pathForResource:@"clickA" ofType:@"aif"];
		NSURL* soundUrlA = [NSURL fileURLWithPath:soundPathA];
		OSStatus statusA = AudioServicesCreateSystemSoundID((CFURLRef)soundUrlA,&clickA);
		
		NSString* soundPathC = [[NSBundle mainBundle]pathForResource:@"clickC" ofType:@"aif"];
		NSURL* soundUrlC = [NSURL fileURLWithPath:soundPathC];
		OSStatus statusC = AudioServicesCreateSystemSoundID((CFURLRef)soundUrlC,&clickC);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withDelegate:(id<LiveViewDelegate>)deleg{
	[self initWithFrame:frame withDelegate:deleg withMaxColumn:4];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	//ここから実況表示フィールド(live)
	//枠を書く
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(context, 1, 1);
	CGContextSetLineWidth(context, 3);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextStrokeRect(context, CGRectMake(3, 3, self.frame.size.width-6, maxColumn*35-6));
	
	//カラー設定
	//[color_wh set];
	
	//textのテキスト表示
	//[text drawInRect:CGRectMake(15, 20, 340, 100) withFont:fnt lineBreakMode:UILineBreakModeCharacterWrap];	
	
}

//テキスト内容をリセットし、再描画を開始するメソッド。主に外部から呼ぶ。
-(void)setTextAndGo:(NSString*)txt{
	CGFloat resetY = 10;
	for(int i = 0; i<[textFieldArray count]; i++){
		//textField内容をリセット
		[[textFieldArray objectAtIndex:i]setText:@""];
		//textFieldの位置をリセット
		CGRect frm = [[textFieldArray objectAtIndex:i]frame];
		frm.origin.y = resetY;
		[[textFieldArray objectAtIndex:i]setFrame:frm];
		resetY += 20;
	}
	if(text) [text autorelease];text=nil;//あったら解放
	text = [[NSMutableString alloc]initWithString:txt];
	current_textField=0;
	//[self drawRect:[self frame]];//これでコンソールにワーニングが出てる。drawRectを呼ぶことによって、システムが許可してないタイミングで枠の描画の命令が行ってたため。なので以下でdrawRectでやってた枠描画以外の処理をそのまま書く。
	
	//timer用変数初期化
	ti=0;
	tj=0;
	tk=0;
	hajime=0;
	[self makeTimer];
}
//上のメソッドに、textIDの設定も追加したメソッド。
-(void)setTextAndGo:(NSString*)txt withTextID:(int)txtID{
	[self setTextAndGo:txt];
	textID = txtID;
}
//上の上のメソッドに、表示終了後実行するメソッドの設定も追加したメソッド。
-(void)setTextAndGo:(NSString*)txt actionAtTextFinished:(SEL)selector userInfo:(id)userInfo target:(id)target{
	
	//targetObj_は参照。retain、releaseでメモリ管理しようとしたがなぜかうまく行かなかった。
	
	//userInfoの参照カウンタを増やしておく（すぐ下の処理時か、dealloc時にrelease送ることになる）
	if(userInfo)[userInfo retain];
	
	//古いuserInfo_をrelease。
	if(userInfo_)[userInfo_ release];userInfo_ = nil;
	
	targetObj_ = target;
	userInfo_ = userInfo;
	selector_ = selector;
	[self setTextAndGo:txt];
}

//一度に全て表示しないで、順番を指定し、ユーザーに三角ボタンを押させてから次のテキストを描画するという形式での表示を設定、開始するメソッド。外部から呼ぶ。
//（要素が一つの配列を引数にした場合は、setTextAndGoと同じ動作をする。）
-(void)setSeqTextAndGo:(NSArray*)txtArray{
	if([txtArray count] > 0){//要素が0個ならば実行しないように
		if(seqTextArray) [seqTextArray release]; seqTextArray=nil;//古いのがあれば解放
		seqTextArray = [[NSMutableArray alloc]initWithArray:txtArray copyItems:YES];//コピーしている
		seqTextMode = YES;
		seqText_i = 0;
		[self seqTextLoopAction];
	}
}
//上のメソッドに、textIDの設定も追加したメソッド。
-(void)setSeqTextAndGo:(NSArray*)txtArray withTextID:(int)txtID{
	[self setSeqTextAndGo:txtArray];
	textID = txtID;
}
//seqTextModeにて、実際にテキストを処理していくメソッド。
-(void)seqTextLoopAction{
	buttonEnable=FALSE;
	if(seqText_i == [seqTextArray count]-1){//最後の回ならば
		seqTextMode = FALSE;
	}
	[self setTextAndGo:[seqTextArray objectAtIndex:seqText_i]];
}

//タイマー作成
-(void)makeTimer{
	if(!timer){
		timer = [NSTimer scheduledTimerWithTimeInterval:2.0f/30.0f
												 target:self
											   selector:@selector(drawText:)
											   userInfo:nil
												repeats:YES];
	}
}

-(void)drawText:(NSTimer*)_timer{
	//NSLog(@"timer");
	if(ti>text.length-1){//テキストの長さの範囲を超える前に、タイマーを止める
		if(timer) [timer invalidate]; timer=nil;
		//ここで、全てのテキストを描画し終わったということになるのかな。
		if(!seqTextMode){//seqTextModeじゃなければ、全てのテキストを描画し終わったので
			//テキストを全て描画し終わったときのアクションを実行。
			[NSTimer scheduledTimerWithTimeInterval:actionDelay_ 
											 target:self selector:@selector(doActionWhenTextEnded) 
										   userInfo:nil repeats:NO];
		}else if(seqTextMode){
			buttonEnable = TRUE;
			seqTextMode_buttonEnable = TRUE;
			moreTextButt.hidden=FALSE; [moreTextButt startBlinking];
		}
		
	}else if([[text substringWithRange:NSMakeRange(ti, 1)]isEqualToString:@"\n"]){//改行コードが含まれていたら、テキストフィールドがいっぱいになったときと同じ処理を行う。
		[self onTextFieldOver];
	}else if(tj<=maxWords){
		AudioServicesPlaySystemSound(clickC);//sound再生
		[[textFieldArray objectAtIndex:current_textField % 6]setText:[text substringWithRange:NSMakeRange(hajime, tj+1)]];
		tj+=1;
		if(tj==maxWords){//テキストフィールドがいっぱいになったとき
			[self onTextFieldOver];
		}
	}
	ti+=1;
}

//テキストフィールドがいっぱいになったときの処理。
-(void)onTextFieldOver{
	hajime=ti+1;//はじめの文字を、これまで書いた次の文字に設定。
	tj=0;//行ごとの文字数の変数を0に初期化。
	current_textField+=1;//描画先のテキストフィールドを次のものに
	tk+=1;//使ったテキストフィールドの数に1足す。
	if(tk >= maxColumn){//一番下のテキストフィールドの文字がいっぱいになった時の処理
		if(tk % maxColumn == 0){//tkが"最大同時表示行数"の倍数なら(overflowなら)
			if(timer) [timer invalidate]; timer=nil;//とりあえずタイマーを止める（変数は初期化されない）
			//カーソルボタンで次のテキストに送るなら
			if(overflowMode == WWYLiveViewOverflowMode_cursorButton){
				moreTextButt.hidden=FALSE; [moreTextButt startBlinking];
				buttonEnable=TRUE;
			//delegateからのアクションで次のテキストに送るなら
			}else if(overflowMode == WWYLiveViewOverflowMode_delegateAction){
				moreTextButt.hidden=FALSE;//三角ボタンは表示だけ
				if([delegate respondsToSelector:@selector(liveViewTextDidOverflow)]){//liveViewTextDidOverflowメソッドを実装していたら
					[delegate liveViewTextDidOverflow];
				}else{//メソッドを実装していない場合は、次に送ってしまう。ユーザ操作できない状況になるのはよくないので。
					[self goNextText];
				}
			//ユーザーからのアクションなしで自動的に次のテキストに送るなら
			}else if(overflowMode == WWYLiveViewOverflowMode_noAction){
				[self goNextText];
			}
		}else{
			[self moveUpTexFields];
		}
	}
}

/*-(void)moreText{
	buttonEnable=FALSE;
	moreTextButt.hidden=YES;
	[self moveUpTexFields];
	[self makeTimer];
}*/

//テキストフィールドを上に上げる処理をまとめた関数
-(void)moveUpTexFields{
	[UIView beginAnimations:@"moveUp" context:NULL];//アニメーションにするならアクティブに。
	for(int i=0;i<[textFieldArray count];i++){
		CGRect frm = [[textFieldArray objectAtIndex:i]frame];
		frm.origin.y -= 20;//動かす。
		[[textFieldArray objectAtIndex:i]setFrame:frm];
	}
	[UIView commitAnimations];//アニメーションにするならアクティブに。
	//上にはみ出したテキストフィールドの文字を消すのと、一番下へ移動する処理。
	[[textFieldArray objectAtIndex:(current_textField - maxColumn) % 6]setText:@""];
	[[textFieldArray objectAtIndex:(current_textField - maxColumn) % 6]setFrame:CGRectMake(20, 110, 340, 30)];
}

//三角ボタンを押したときのアクション。
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if ([touch view] == moreTextButt) {
		if(buttonEnable==TRUE){
			//sound再生
			AudioServicesPlaySystemSound(clickA);
			buttonEnable=FALSE;
			//moreTextButt.hidden=YES; [moreTextButt stopBlinking];
			[self goNextText];
		}
		//NSLog(@"Button Up");
	}		
}

//overflowしていた次のテキストを描画する。
-(void)goNextText{
	if(!seqTextMode_buttonEnable){
		//if(buttonEnable==TRUE){
			//sound再生
			//AudioServicesPlaySystemSound(clickA);
			//以下、次へテキストを送るボタンアクション。
			//buttonEnable=FALSE;
			moreTextButt.hidden=YES; [moreTextButt stopBlinking];
			[self moveUpTexFields];
			[self makeTimer];
		//}
	}else{//seqTextMode_buttonEnableのときに押されたら
		//sound再生
		AudioServicesPlaySystemSound(clickA);
		seqTextMode_buttonEnable = FALSE;
		if(buttonEnable==TRUE){
			buttonEnable=FALSE;
			seqText_i += 1;
			[self seqTextLoopAction];
		}
	}
}
//テキストを最後まで描画し終わったときのアクションを実行。
-(void)doActionWhenTextEnded{
	//targetObj_のメソッドselector_を実行
	if([targetObj_ respondsToSelector:selector_]){
		objc_msgSend(targetObj_, selector_, userInfo_);
	}
	
	//プロトコルメソッドをdelegに送る。
	if([delegate respondsToSelector:@selector(liveViewDrawEndedWithID:)]){//liveViewDrawEndedWithID:メソッドを実装していたら
		[delegate liveViewDrawEndedWithID:textID];//textIDがない場合は、textID=0送信される。
	}
}

//メモリ解放される準備をする。タイマー動いてたらタイマー止めたり。
-(void)close{
	if(timer) [timer invalidate]; timer=nil;
}

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(textFieldArray){
		for(int i=0;i<[textFieldArray count];i++){
			[[textFieldArray objectAtIndex:i]removeFromSuperview];
			[[textFieldArray objectAtIndex:i]autorelease];
		}
		[textFieldArray autorelease]; textFieldArray = nil;
	}
	if(moreTextButt){
		[moreTextButt removeFromSuperview];[moreTextButt close];[moreTextButt autorelease];moreTextButt=nil;
	}
	if(seqTextArray){
		[seqTextArray removeAllObjects];
		[seqTextArray autorelease];
	}
	if(text) [text autorelease]; text=nil;
	
	if(userInfo_) [userInfo_ release];userInfo_ = nil;
	selector_ = nil;
	
	[super dealloc];
	
}


@end
