//
//  EnemyImagePickerViewController.m
//  WWY2
//
//  Created by locolocode on 11/12/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "EnemyImagePickerViewController.h"

@implementation EnemyImagePickerViewController

- (void)dealloc {
    if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(enemyImgPickerHelper_) [enemyImgPickerHelper_ release];
    [super dealloc];
}

-(id)initWithViewFrame:(CGRect)frame target:(id)target selector:(SEL)selector userInfo:(id)userInfo selectorWhenCancel:(SEL)selectorWhenCancel {
	if(self = [super initWithViewFrame:frame target:target selector:selector userInfo:userInfo selectorWhenCancel:selectorWhenCancel]){
        self.showNameLabel = YES;
    }
    return self;
}

-(UIView*)initPickerView{
    enemyImgPickerHelper_ = [[EnemyImagePickerHelper alloc]init];
    enemyImgPickerHelper_.pickerViewController = self;
    UIPickerView* enemyImgPickerView = [[[UIPickerView alloc]initWithFrame:self.view.frame]autorelease];
    enemyImgPickerView.delegate = enemyImgPickerHelper_;
    enemyImgPickerView.dataSource = enemyImgPickerHelper_;
    
    float marginX = 20; float marginY = 80;
    enemyImgPickerView.frame = CGRectMake(marginX, marginY, self.view.frame.size.width-marginX*2, enemyImgPickerView.frame.size.height);
    
    return (UIView*)enemyImgPickerView;
}

@end
