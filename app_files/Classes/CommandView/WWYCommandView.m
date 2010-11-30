//
//  WWYCommandView.m
//  Version 2.0
//
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//arrowButonが、上に出っ張ってないタイプのCommandView。

#import "WWYCommandView.h"
#import "WWYCommandColumnView.h"
#import "WWYCommandArrowView.h"
#import "WWYCommandFrameView.h"

@implementation WWYCommandView
@synthesize touchEnable;
@synthesize commandViewId;
@synthesize commandColumnArray;

//クラス内部で使用する初期化処理
-(void)initialize{
	commandViewId = 0;
	spacing = 35;//各コマンドテキストの上下の間隔。
	self.multipleTouchEnabled = FALSE;//このView内でのマルチタッチを許可しない。
	self.exclusiveTouch = YES;//このViewの後、他のViewのタッチを許可しない。(YESで許可しない)
	touchEnable = YES;
	maxColumnAtOnce = 1;
	startColumn = 0;
	brinkingColumnNumber=-1; //初期値は-1に。この変数が設定されているかどうかは値が-1かどうかで判定する。
	
	//backgroundcolorを透明に
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	
	//次ページへ送るボタンの大きさ
	arrowSize = 14;
	arrowPadding = 4;
	arrowButtonMargin = (arrowSize+arrowPadding*2)/2-2;
	
	//一番上のカラムのY位置
	yTop = 23+arrowButtonMargin;
	
	//commandColumnViewを入れるarrayを生成
	commandColumnArray = [[NSMutableArray alloc]init];
	
	//sound
	NSString* soundPathA = [[NSBundle mainBundle]pathForResource:@"clickA" ofType:@"aif"];
	NSURL* soundUrlA = [NSURL fileURLWithPath:soundPathA];
	OSStatus statusA = AudioServicesCreateSystemSoundID((CFURLRef)soundUrlA,&clickA);
	
	//次のページに送るボタンを生成
	arrowButton =[[WWYCommandArrowView alloc]initWithFrame:CGRectMake(self.frame.size.width-40,0,arrowSize+arrowPadding*2,arrowSize+arrowPadding*2) withArrowSize:arrowSize  withPadding:arrowPadding];
}

//initメソッド1（今後こちらをメインに）
- (id)initWithFrame:(CGRect)frame target:(id)target maxColumnAtOnce:(int)maxColumn{
	if (self = [super initWithFrame:frame]) {
		[self initialize];
		maxColumnAtOnce = maxColumn;
		target_ = target;
	}
	return self;
}
//コマンドのテキストと、実行するメソッドの追加
-(void)addCommand:(NSString*)command action:(SEL)selector userInfo:(id)userInfo{
	[self insertCommand:command action:selector userInfo:userInfo AtIndex:[commandColumnArray count]];
}
//コマンドのテキストと、実行するメソッドをindex指定して挿入
-(void)insertCommand:(NSString*)command action:(SEL)selector userInfo:(id)userInfo AtIndex:(int)index{
	float yPos = index % maxColumnAtOnce * spacing + yTop;
	[commandColumnArray insertObject:[[[WWYCommandColumnView alloc]initWithFrame:CGRectMake(spacing/2, yPos, self.frame.size.width-30, spacing) 
																		text:command 
																	  target:target_ 
																	 selector:selector 
																	 userInfo:userInfo]
								   autorelease]
							 atIndex:index];
	
	//各commandColumnViewの、 columnNo（何番目のコマンドかを格納する変数）を設定
	for(int i=0; i++; i<[commandColumnArray count]){
		[[commandColumnArray objectAtIndex:i]setColumnNo:i];
	}
	
	//枠のViewを生成、表示。
	frameView_ = [[WWYCommandFrameView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	[self addSubview:frameView_];
	
	//ページ送りボタンの表示
	if([commandColumnArray count] > maxColumnAtOnce){
		[self addSubview:arrowButton];
	}
	
	[self adjustHeight];
	[self addSubviewColumns];
}

//コマンドを消去する。indexで何番目か指定。
-(void)removeCommandAtIndex:(int)index{
	[[commandColumnArray objectAtIndex:index]removeFromSuperview];
	[commandColumnArray removeObjectAtIndex:index];
}

//initメソッド2（旧バージョンとの互換。必要ないなら削除）
- (id)initWithFrame:(CGRect)frame withCommandTextArray:(NSArray*)array withMaxColumn:(int)myMaxColumn withDelegate:(id <WWYCommandViewDelegate>)deleg withCommandViewId:(int)cmdViewId{
    if (self = [super initWithFrame:frame]) {
		[self initialize];
		commandViewId = cmdViewId; maxColumnAtOnce = myMaxColumn; delegate = deleg;
		
		NSMutableArray* commandArray = [[NSMutableArray alloc]initWithArray:array copyItems:true];
		
		//commandColumnViewの追加。
		NSString* columnString ;
		int i = 0; float yPos = yTop;
		for (columnString in commandArray) {
			if(i % maxColumnAtOnce == 0) { yPos = yTop; }
			[commandColumnArray addObject:[[WWYCommandColumnView alloc]initWithFrame:CGRectMake(spacing/2, yPos, self.frame.size.width-30, spacing)
																			withText:[NSMutableString stringWithString:columnString] withDelegate:delegate withCommandView:self]];
			[[commandColumnArray lastObject]autorelease];//各CommandColumnViewをautoreleaseしておく
			yPos += spacing;
			i+=1;
		}
		//各commandColumnViewの、 columnNo（何番目のコマンドかを格納する変数）を設定。
		for (int i=0; i<[commandColumnArray count]; i++) {
			[[commandColumnArray objectAtIndex:i]setColumnNo:i];
		}
		
		//枠のViewを生成、表示。
		frameView_ = [[WWYCommandFrameView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:frameView_];
		
		//ページ送りボタンの表示
		if([commandColumnArray count] > maxColumnAtOnce){
			[self addSubview:arrowButton];
		}
		
		[self adjustHeight];
		[self addSubviewColumns];
		
		//release
		[commandArray release];
	}
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	//枠を描くのは別クラスにした。位置や大きさを外部から変えたときに対応するため。
	/*
	//下地になる四角を書く
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(context, 0, 1);
	CGContextFillRect(context, CGRectMake(3, 3,  self.frame.size.width-6, self.frame.size.height-6));//arrowButtonの上に出っ張ってる分を考慮してy値を指定。	
	
	//枠を書く
	//CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(context, 1, 1);
	CGContextSetLineWidth(context, 3);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	//CGContextStrokeRect(context, CGRectMake(3, 3+arrowButtonMargin,  self.frame.size.width-6, self.frame.size.height-6-arrowButtonMargin));//arrowButtonの上に出っ張ってる分を考慮してy値を指定。
	CGContextStrokeRect(context, CGRectMake(3, 3,  self.frame.size.width-6, self.frame.size.height-6));//arrowButtonの上に出っ張ってる分を考慮してy値を指定。
*/
}
//高さの自動設定。格納するコマンドテキストの数によって決まる。
-(void)adjustHeight{
	displayColumnNum = [self getDisplayColumnNum];
	CGRect myFrame = self.frame;
	myFrame.size.height = (displayColumnNum+1) * spacing + arrowButtonMargin;
	[self setFrame:myFrame];
	//枠のframeも設定
	[frameView_ setFrame:CGRectMake(0, 0, myFrame.size.width, myFrame.size.height)];
}
//位置や大きさを変更する。
-(void)changeFrame:(CGRect)newFrame{
	[self setFrame:newFrame];
	[self adjustHeight];
}
//コマンド行の（再）表示
-(void)addSubviewColumns {
	displayColumnNum = [self getDisplayColumnNum];
	
	for (int i=startColumn; i < startColumn + displayColumnNum; i++) {
		[self addSubview:[commandColumnArray objectAtIndex:i]];
	}
}

//現在表示すべきカラム数を得る。
-(int)getDisplayColumnNum{
	int _displayColumnNum;
	if([commandColumnArray count] - startColumn < maxColumnAtOnce){
		_displayColumnNum = [commandColumnArray count] - startColumn;
	}else{
		_displayColumnNum = maxColumnAtOnce;
	}
	return _displayColumnNum;	
}

-(void)removeFromSuperviewColumns {	
	for (int i=startColumn; i<displayColumnNum; i++) {
		[[commandColumnArray objectAtIndex:i]removeFromSuperview];
		//NSLog(@"(WWYCommandView)cmdclmview%d\n",[[commandColumnArray objectAtIndex:i] retainCount]);
	}
}

/*-(void)cancel{
		[self removeFromSuperview];		
		NSLog(@"(CommandView2)selfRcount%d\n",[self retainCount]);
		//[self release];//リリースしない？リリースすると今のバトルロジックだとあるステップでエラーになる。（いろいろな参照等を整理してすっかりdeallocできるなら、リリースした方がいいのだが。いや、呼び出し元でreleaseした方が良い。
}*/

-(void)setIDForColumnsFromNSNumberArray:(NSArray*)myIDArray{
	NSArray* IDArray = [NSArray arrayWithArray:myIDArray copyItems:true];
	for(int i=0; i<[commandColumnArray count] && i<[IDArray count]; i++){
		[[commandColumnArray objectAtIndex:i]setId:[[IDArray objectAtIndex:i]intValue]];
	}
}
-(void)setTitle:(NSString*)title withWidth:(CGFloat)width withHeight:(CGFloat)heightOrZero{
	if(heightOrZero == 0) heightOrZero = 19.0f;
	NSString* titleStr = [[NSString alloc]initWithString:title];
	titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-width)/2, 0, width, heightOrZero)];
	titleLabel.text = titleStr;	
	titleLabel.backgroundColor = [UIColor blackColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont systemFontOfSize:16.0f];
	//titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	//titleLabel.adjustsFontSizeToFitWidth = TRUE;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.userInteractionEnabled = false;
	[self addSubview: titleLabel];
}
//指定した番号のcommandColumnViewのarrowボタンを点滅させる。
-(void)columnViewArrowStartBlinking:(int)columnViewNumber{
	if(columnViewNumber >= 0 && columnViewNumber < [commandColumnArray count]){
		if(brinkingColumnNumber != -1) [self columnViewArrowStopBlinking:brinkingColumnNumber];//brinkingColumnNumberが設定されてれば（すでに点滅されていれば）点滅ストップ。
		brinkingColumnNumber = columnViewNumber;
		[[commandColumnArray objectAtIndex:columnViewNumber]arrowStartBlinking];
	}
}
//指定した番号のcommandColumnViewのarrowボタンの点滅をストップさせる。
-(void)columnViewArrowStopBlinking:(int)columnViewNumber{
	if(columnViewNumber >= 0 && columnViewNumber < [commandColumnArray count]){
		[[commandColumnArray objectAtIndex:columnViewNumber]arrowStopBlinking];
	}
}

//デフォルトの状態にするメソッド。（ページ送りを初期値にするなど。）外部から呼ぶ。
-(void)resetToDefault{
	[self removeFromSuperviewColumns];
	startColumn = 0;
	[self addSubviewColumns];
	//touchEnable = true;//ここで必ず操作可能になるのではなく、外部からコントロールできた方がいいだろう。
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if(touchEnable){
		UITouch *touch = [touches anyObject];
		if(brinkingColumnNumber != -1) [self columnViewArrowStopBlinking:brinkingColumnNumber];//brinkingColumnNumberが設定されてれば（すでに点滅されていれば）点滅ストップ。
		if([touch view] == arrowButton) {
			selecting = -1; //selectingを-1にしておく。何も選択されていないというフラグになる。
		}else{
			CGPoint selectingPos = [touch locationInView:self];
			selecting = floor((selectingPos.y-yTop)/spacing)+startColumn;
			if(selecting < startColumn || selecting > startColumn+displayColumnNum-1){ //selectingが現在表示中のカラムの外の範囲だったら
				selecting = -1 ; //selectingを-1にして、全てのカラムにhideArrowする。
			}
			for (int i=0; i<[commandColumnArray count]; i++) {
				if(i == selecting) {
					[[commandColumnArray objectAtIndex:i]showArrow];
				}else {
					[[commandColumnArray objectAtIndex:i]hideArrow];
				}
			}
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if(touchEnable){
		UITouch *touch = [touches anyObject];
		if([touch view] == arrowButton) {
			selecting = -1; //selectingを-1にしておく。何も選択されていないというフラグになる。
		}else{
			CGPoint selectingPos = [touch locationInView:self];
			selecting = floor((selectingPos.y-yTop)/spacing)+startColumn;
//			NSLog(@"startColumn:%d",startColumn),NSLog(@"displayColumnNum:%d",displayColumnNum),NSLog(@"selecting:%d",selecting);
			if(selecting < startColumn || selecting > startColumn+displayColumnNum-1 //selectingが現在表示中のカラムの外の範囲になるか、
			   || selectingPos.x < 0 || selectingPos.x > self.frame.size.width){ //selectingPosがこのViewから左右に外れたら
				selecting = -1 ; //selectingを-1にして、全てのカラムにhideArrowする。
			}
			for (int i=0; i<[commandColumnArray count]; i++) {
				if(i == selecting){
					[[commandColumnArray objectAtIndex:i]showArrow];
					//sound再生
					//AudioServicesPlaySystemSound(clickB);
				} else {
					[[commandColumnArray objectAtIndex:i]hideArrow];
				}
			}
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(touchEnable){
		UITouch *touch = [touches anyObject];
		CGPoint selectingPos = [touch locationInView:self];
		if([touch view] == arrowButton) {
			[self removeFromSuperviewColumns];
			startColumn += maxColumnAtOnce;
			if (startColumn > [commandColumnArray count]){startColumn = 0;}
			[self addSubviewColumns];
			//sound再生
			AudioServicesPlaySystemSound(clickA);
		}else if([touch view] == titleLabel) {//titleLabelをタッチしても何も起こらないように条件から外す。
			
		}else if(selectingPos.y > 10.0 && selectingPos.y < self.frame.size.height - 10.0){//タッチイベントがこのビューの少しpaddingをとった領域の中に入ってるかを見ている。
			if(selecting != -1) {//何かが選択されていれば
				touchEnable = false;
				for (int i=0; i<[commandColumnArray count]; i++) {
					if(i == selecting){
						
						[[commandColumnArray objectAtIndex:i]hideArrow];
						//sound再生
						AudioServicesPlaySystemSound(clickA);
						[[commandColumnArray objectAtIndex:i]enterCommand];
					}
				}
			}
		}
	}
}

- (void)dealloc {
	NSLog(@"WWYCommandView--------------dealloc!!!!!!!!!!");
	//NSLog(@"(WWYCommandView)commandColumnArrayRcount%d\n",[commandColumnArray retainCount]);
	//NSLog(@"(WWYCommandView)arrowButtonRcount%d\n",[arrowButton retainCount]);
	//NSLog(@"(WWYCommandView)delegateRcount%d\n",[delegate retainCount]);
	
	[self removeFromSuperviewColumns];//各commandColumnViewをremoveFromSuperviewする
	[frameView_ removeFromSuperview];
	[arrowButton removeFromSuperview];
	/*WWYCommandColumnView* cmdclmview;
	for(cmdclmview in commandColumnArray){
		NSLog(@"(WWYCommandView)cmdclmview%d\n",[cmdclmview retainCount]);
		//[cmdclmview autorelease];
	}*/
	
	[commandColumnArray autorelease];
	[frameView_ autorelease];
	[arrowButton autorelease];
	//[delegate release];
	[super dealloc];
}

@end
