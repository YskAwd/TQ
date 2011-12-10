//
//  DatePickerViewController.h
//  WWY2
//
//  Created by awaBook on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWY2PickerViewController.h"

@interface DatePickerViewController : WWY2PickerViewController {
	UIDatePicker *datePicker_;
}

@property (assign) UIDatePicker *datePicker;
@end
