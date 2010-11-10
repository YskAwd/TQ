//
//  DatePickerViewController.h
//  WWY2
//
//  Created by awaBook on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWYCommandView.h"


@interface DatePickerViewController : UIViewController {
	UIDatePicker *datePicker_;
	WWYCommandView *submitCommandView_;
	
	id target_;
	SEL selector_;
	id userInfo_;
	SEL selectorWhenCancel_;
}
-(id)initWithViewFrame:(CGRect)frame target:(id)target selector:(SEL)selector userInfo:(id)userInfo selectorWhenCancel:(SEL)selectorWhenCancel;
@property (assign) UIDatePicker *datePicker;
@end
