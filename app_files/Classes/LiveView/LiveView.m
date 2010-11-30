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

- (id)initWithLocation:(CGPoint)location withDelegate:(id<LiveViewDelegate>)deleg{
	CGRect frame = CGRectMake(location.x, location.y, 366, 106); 
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		delegate = deleg;
		textID = nil;
		current_textField=0;
		//最大同時表示行数
		maxColumn = 3;
		//フォント、カラー
		fnt = [UIFont systemFontOfSize:16.0f];
		color_wh=[UIColor whiteColor];
		//color_bl=[UIColor blackColor];
		color_bl=[UIColor colorWithWhite:0 alpha:0];
		
		buttonEnable=FALSE;
		
		//moreTextButt=[[CursorButtonView alloc]initWithFrame:CGRectMake(180, 90, 20, 20)];
		moreTextButt=[[CursorButtonView alloc]initWithFrame:CGRectMake(172, 95, 25, 10)];
		
		
		textFieldArray=[[NSMutableArray alloc]initWithObjects:[[UITextView alloc]initWithFrame:CGRectMake(20, 10, 340, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 30, 340, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 50, 340, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 70, 340, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 90, 340, 30)],
						[[UITextView alloc]initWithFrame:CGRectMake(20, 110, 340, 30)],nil];
		
		for(int i=0;i<[textFieldArray count];i++){
			[[textFieldArray objectAtIndex:i]setFont:fnt];
			[[textFieldArray objectAtIndex:i]setEditable:FALSE];
			[[textFieldArray objectAtIndex:i]setBackgroundColor:color_bl];
			[[textFieldArray objectAtIndex:i]setTextColor:color_wh];
			[self addSubview:[textFieldArray objectAtIndex:i]];
		}
		[self addSubview:moreTextButt];
		moreTextButt.hidden=YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	//ここから実況表示フィールド(live)
	//枠を書く
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(context, 1, 1);
	CGContextSetLineWidth(context, 3);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextStrokeRect(context, CGRectMake(3, 3, 360, 100));
	
	//カラー設定
	//[color_wh set];
	
	//textのテキスト表示
	//[text drawInRect:CGRectMake(15, 20, 340, 100) withFont:fnt lineBreakMode:UILineBreakModeCharacterWrap];	
	
}

//テキスト内容をリセットし、再描画を開始するメソッド。主に外部から呼ぶ。
-(void)setTextAndGo:(NSMutableString*)txt{
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
	text=txt;
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
-(void)setTextAndGo:(NSMutableString*)txt withTextID:(int)txtID{
	[self setTextAndGo:txt];
	textID = txtID;
}
//一度に全て表示しないで、順番を指定し、ユーザーに三角ボタンを押させてから次のテキストを描画するという形式での表示を設定、開始するメソッド。外部から呼ぶ。
//（要素が一つの配列を引数にした場合は、setTextAndGoと同じ動作をする。）
-(void)setSeqTextAndGo:(NSArray*)txtArray{
	if([txtArray count] > 0){//要素が0個ならば実行しないように
		[seqTextArray release];//古いのがあればリリース
		seqTextArray = [[NSArray alloc]initWithArray:txtArray copyItems:YES];//コピーしている
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

//タイマー
-(void)makeTimer{
	timer = [NSTimer scheduledTimerWithTimeInterval:.05f
											 target:self
										   selector:@selector(drawText:)
										   userInfo:nil
											repeats:YES];
}

-(void)drawText:(NSTimer*)timer{
	if(ti>text.length-1){//テキストの長さの範囲を超える前に、タイマーを止める
		[timer invalidate];
		//ここで、全てのテキストを描画し終わったということになるのかな。
		if(!seqTextMode){//seqTextModeじゃなければ、全てのテキストを描画し終わったので
			//プロトコルメソッドをdelegに送る。
			[delegate liveViewDrawEndedWithID:textID];//textIDがない場合は、textID=0送信される。
		}else if(seqTextMode){
			buttonEnable = TRUE;
			seqTextMode_buttonEnable = TRUE;
			moreTextButt.hidden=FALSE;
		}
	}else if([[text substringWithRange:NSMakeRange(ti, 1)]isEqualToString:@"\n"]){//改行コードが含まれていたら、テキストフィールドがいっぱいになったときと同じ処理を行う。
		[self onTextFieldOver];
	}else if(tj<=19){
		[[textFieldArray objectAtIndex:current_textField % 6]setText:[text substringWithRange:NSMakeRange(hajime, tj+1)]];
		tj+=1;
		if(tj==19){//テキストフィールドがいっぱいになったとき
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
		if(tk % maxColumn == 0){//tkが"最大同時表示行数"の倍数なら
			[timer invalidate];//とりあえずタイマーを止める（変数は初期化されない）
			moreTextButt.hidden=FALSE;
			buttonEnable=TRUE;
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
		moreTextButt.hidden=YES;
		if(!seqTextMode_buttonEnable){
			if(buttonEnable==TRUE){
				//以下、次へテキストを送るボタンアクション。
				buttonEnable=FALSE;
				[self moveUpTexFields];
				[self makeTimer];
			}
		}else{//seqTextMode_buttonEnableのときに押されたら
			seqTextMode_buttonEnable = FALSE;
			if(buttonEnable==TRUE){
				buttonEnable=FALSE;
				seqText_i += 1;
				[self seqTextLoopAction];
			}
		}

		//NSLog(@"Button Up");
	}		
}

- (void)dealloc {
    [super dealloc];
	for(int i=0;i<[textFieldArray count];i++){
		[[textFieldArray objectAtIndex:i]release];
	}
	[textFieldArray release];
}


@end
