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

- (void)dealloc {
    if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(pickerView_) [pickerView_ removeFromSuperview];//autorelease済
	if(submitCommandView_) [submitCommandView_ removeFromSuperview];//autorelease済
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
		
		self.view.opaque = YES;
		self.view.backgroundColor = [UIColor blackColor];
		
        pickerView_ = [self initPickerView];
        
		float submitCommandViewWidth = 120;
		CGRect submitCommandViewFrame = CGRectMake(self.view.frame.size.width-submitCommandViewWidth-20,
												   self.view.frame.size.height*2/3, 
												   submitCommandViewWidth, 1);
		submitCommandView_ = [[[WWYCommandView alloc]initWithFrame:submitCommandViewFrame target:self maxColumnAtOnce:2]autorelease];
		[submitCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(submitCommand) userInfo:nil];
		[submitCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(cancelCommand) userInfo:nil];
		
		[self.view addSubview:pickerView_];
		[self.view addSubview:submitCommandView_];
	}return self;
}

-(UIView*)initPickerView{
    return nil;
}

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

@end
