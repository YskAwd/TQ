    //
//  DatePickerViewController.m
//  WWY2
//
//  Created by awaBook on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController
@synthesize datePicker = datePicker_;

- (void)dealloc {
	NSLog(@"DatePickerViewController-------------------------------dealloc!!!");
	if(datePicker_) [datePicker_ removeFromSuperview];//autorelease済
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
		
		datePicker_ = [[[UIDatePicker alloc]init]autorelease];
		float marginX = 20; float marginY = 80;
		datePicker_.frame = CGRectMake(marginX, marginY, self.view.frame.size.width-marginX*2, datePicker_.frame.size.height);
		
		float submitCommandViewWidth = 120;
		CGRect submitCommandViewFrame = CGRectMake(self.view.frame.size.width-submitCommandViewWidth-20,
												   self.view.frame.size.height*2/3, 
												   submitCommandViewWidth, 1);
		submitCommandView_ = [[[WWYCommandView alloc]initWithFrame:submitCommandViewFrame target:self maxColumnAtOnce:2]autorelease];
		[submitCommandView_ addCommand:NSLocalizedString(@"fix",@"") action:@selector(submitCommand) userInfo:nil];
		[submitCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(cancelCommand) userInfo:nil];
		
		[self.view addSubview:datePicker_];
		[self.view addSubview:submitCommandView_];
	}return self;
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
