//
//  WWYCommandColumnView.m
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWYCommandColumnView.h"
#import "WWYCommandView.h"
#import "WWYCommandArrowView.h"


@implementation WWYCommandColumnView
@synthesize text;
@synthesize Id;
@synthesize columnNo;
@synthesize mySize;
@synthesize delegate;

//基本初期化処理（内部で使用）
-(void)initialize{
		Id = 0;//とりあえず0を入れておく。必要ならば外部から設定。
		arrow =[[WWYCommandArrowView alloc]initWithFrame:CGRectMake(0,3,13,13)];
}
//initメソッド1
- (id)initWithFrame:(CGRect)frame text:(NSString*)commandText target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo{
    if (self = [super initWithFrame:frame]) {
		[self initialize];
		text = [[NSMutableString alloc]initWithString:commandText];
		targetObj_ = target;
		selector_ = aSelector;
		userInfo_ = userInfo;
		[userInfo_ retain];
    }
    return self;
}

//initメソッド2
- (id)initWithFrame:(CGRect)frame withText:(NSString*)commandText withDelegate:(id <WWYCommandViewDelegate>)deleg withCommandView:(WWYCommandView*)cmdView{
    if (self = [super initWithFrame:frame]) {
		[self initialize];
		text = [[NSMutableString alloc]initWithString:commandText];
		delegate = deleg;
		commandView = cmdView;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
	UIColor* color_wh = [UIColor whiteColor];
	[color_wh set];
	mySize = [text drawAtPoint:CGPointMake(18, 0) withFont:[UIFont systemFontOfSize:16.0f]];
	//NSLog(@"size:%f",mySize.width);
}

-(void)enterCommand{
	//targetObj_のメソッドselector_を実行
	if([targetObj_ respondsToSelector:selector_]){
		objc_msgSend(targetObj_, selector_, userInfo_);
	}
	//delegateが設定されていればカラムのIdやテキスト等を通知
	if(delegate){
		[delegate commandPushedWithCommandString:text withColumnNo:columnNo withColumnID:Id withCommandViewId:commandView.commandViewId];
	}
}

-(void)showArrow{
	[self addSubview: arrow];
	//selected = true;
}

-(void)hideArrow{
	[arrow removeFromSuperview];
	//selected = false;
}
//arrowボタン明滅スタート
-(void)arrowStartBlinking{
	[arrow startBlinking];
	[self showArrow];
}
//arrowボタン明滅ストップ
-(void)arrowStopBlinking{
	//[self hideArrow];
	[arrow stopBlinking];
}

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	
	//NSLog(@"(WWYCommandColumnView)textRcount%d\n",[text retainCount]);
	//NSLog(@"(WWYCommandColumnView)arrowRcount%d\n",[arrow retainCount]);
	[self arrowStopBlinking];
	[text release];
	[arrow close];[arrow release];
	[userInfo_ release];
    [super dealloc];
}


@end
