//
//  EnemyImagePickerHelper.h
//  WWY2
//
//  Created by locolocode on 11/12/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnemyImagePickerHelper : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>{
    CGFloat imageSize_;//モンスター画像の一辺の大きさ
}
//指定したenemyImageIdのUIImageを返す
-(UIImage*)enemyImageViewWithId:(int)enemyImageId;
@end
