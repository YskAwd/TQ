//
//  EnemyImagePickerHelper.m
//  WWY2
//
//  Created by locolocode on 11/12/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "EnemyImagePickerHelper.h"
#import "WWYHelper_DB.h"

@implementation EnemyImagePickerHelper

-(id)init{
	if(self = [super init]){
        imageSize_ = 192.0;
	}
    return self;
}

#pragma mark -
#pragma mark UIPickerViewDelegate プロトコルメソッド

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view{
    //引数viewが再利用できるならそのまま使う
    UIImageView* imageView = (UIImageView*)view;
    //if(!imageView){
        imageView = [[[UIImageView alloc]initWithImage:[[WWYHelper_DB helperDB]getEnemyImageViewWithId:row+1]]autorelease];
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageSize_, imageSize_);
    //}
    return imageView;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return imageSize_;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return imageSize_;
}

#pragma mark -
#pragma mark UIPickerViewDataSource プロトコルメソッド
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 6;
}

@end
