//
//  WWY2PickerViewController.m
//  WWY2
//
//  Created by locolocode on 11/12/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WWY2PickerViewController.h"

@implementation WWY2PickerViewController
@synthesize pickerView = pickerView_;
@synthesize nameLabel = nameLabel_;
//@synthesize showNameLabel = showNameLabel_;

- (void)dealloc {
    if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	//if(pickerView_) [pickerView_ removeFromSuperview];//autorelease済
	//if(submitCommandView_) [submitCommandView_ removeFromSuperview];//autorelease済
    if (nameLabel_) [nameLabel_ release];
    if(nameLabel_waku_) [nameLabel_waku_ release];
	if(target_) [target_ release];
	if(userInfo_)[userInfo_ release];
    [super dealloc];
}

-(id)initWithViewFrame:(CGRect)frame target:(id)target selector:(SEL)selector userInfo:(id)userInfo selectorWhenCancel:(SEL)selectorWhenCancel {
	if(self = [super init]){
		self.view.frame = frame;
		target_ = target; [target_ retain];
		selector_ = selector;
		userInfo_ = userInfo; [userInfo_ retain];
		selectorWhenCancel_ = selectorWhenCancel;
        showNameLabel_ = NO;
		
		self.view.opaque = YES;
		self.view.backgroundColor = [UIColor blackColor];
		
        pickerView_ = [self initPickerView];
        
        CGRect nameLabelFrame = [self getNameLabelFrame];
        nameLabel_ = [[UILabel alloc]initWithFrame:nameLabelFrame];
        nameLabel_.backgroundColor = [UIColor blackColor];
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = [UIFont systemFontOfSize:16];
        nameLabel_.textAlignment = UITextAlignmentCenter;
        
        nameLabel_waku_ = [[UIImageView alloc]initWithFrame:nameLabelFrame];
        UIImage *stretchable_waku_img = [[UIImage imageNamed:@"menu_waku.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        nameLabel_waku_.image = stretchable_waku_img;
        
        CGRect submitCommandViewFrame = [self getSubmitCommandViewFrame];
        submitCommandView_ = [[[WWYCommandView alloc]initWithFrame:submitCommandViewFrame target:self maxColumnAtOnce:2]autorelease];
        [submitCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(submitCommand) userInfo:nil];
        [submitCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(cancelCommand) userInfo:nil];

		[self resetUIs];
	}return self;
}

-(UIView*)initPickerView{
    return nil;
}
#pragma mark -決定コマンド
-(void)submitCommand{
	if([target_ respondsToSelector:selector_]){
		objc_msgSend(target_, selector_, userInfo_);
	}
	
}
-(void)cancelCommand{
	if([target_ respondsToSelector:selectorWhenCancel_]){
		objc_msgSend(target_, selectorWhenCancel_);
	}
}

#pragma mark -プロパティセッター
-(void)setShowNameLabel:(BOOL)showNameLabel{
    showNameLabel_ = showNameLabel;
    [self resetUIs];
}
-(BOOL)getShowNameLabel{
    return showNameLabel_;
}
#pragma mark -UI関連
#pragma mark UI部品のframe設定・view追加
-(void)resetUIs{
    submitCommandView_.frame = [self getSubmitCommandViewFrame];
    [self.view addSubview:pickerView_];
    [self.view addSubview:submitCommandView_];
    if(showNameLabel_) {
        [self.view addSubview:nameLabel_];
        [self.view addSubview:nameLabel_waku_];
    }
}
#pragma mark nameLabelのframe生成
-(CGRect)getNameLabelFrame{
    float nameLabelWidth = 150;
    float nameLabelHeight = 40;
    float nameLabelMarginTop = 30;
    CGRect frame = CGRectMake((self.view.frame.size.width-nameLabelWidth)/2
                                  , nameLabelMarginTop,
                                  nameLabelWidth, nameLabelHeight);
    return frame;
}
#pragma mark submitCommandView_のframe生成
-(CGRect)getSubmitCommandViewFrame{
    float submitCommandViewWidth = 120;
    CGRect submitCommandViewFrame = CGRectMake(self.view.frame.size.width-submitCommandViewWidth-20,
                                               self.view.frame.size.height*2/3, 
                                               submitCommandViewWidth, 1);
    //if(showNameLabel_) submitCommandViewFrame.origin.y += nameLabel_.frame.size.height;
    return submitCommandViewFrame;
}
@end
