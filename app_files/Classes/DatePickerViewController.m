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

-(UIView*)initPickerView{
        datePicker_ = [[[UIDatePicker alloc]init]autorelease];
        float marginX = 20; float marginY = 80;
        datePicker_.frame = CGRectMake(marginX, marginY, self.view.frame.size.width-marginX*2, datePicker_.frame.size.height);
    return (UIView*)datePicker_;
}

@end
