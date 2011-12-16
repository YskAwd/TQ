//
//  WWY2PickerViewController.h
//  WWY2
//
//  Created by locolocode on 11/12/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWYCommandView.h"

@interface WWY2PickerViewController : UIViewController{
    UIView* pickerView_;
    WWYCommandView *submitCommandView_;
    UILabel* nameLabel_;
    UIImageView* nameLabel_waku_;
    BOOL showNameLabel_;
    
    id target_;
    SEL selector_;
    id userInfo_;
    SEL selectorWhenCancel_;
}
-(id)initWithViewFrame:(CGRect)frame target:(id)target selector:(SEL)selector userInfo:(id)userInfo selectorWhenCancel:(SEL)selectorWhenCancel;
-(UIView*)initPickerView;
-(CGRect)getNameLabelFrame;//nameLabelのframe生成
-(CGRect)getSubmitCommandViewFrame;//submitCommandView_のframe生成
@property (assign) UIView* pickerView;
@property BOOL showNameLabel;
@property (readonly) UILabel* nameLabel;
@end
