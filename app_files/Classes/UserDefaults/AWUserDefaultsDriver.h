//
//  AWUserDefaultsDriver.h
//  LocationTweet
//
//  Created by AWorkStation on 10/12/13.
//  Copyright 2010 Japan. All rights reserved.
//
//NSUserDefaultsのサブクラスにしようと思っていたが、standardUserDefaultsがうまくいかなかったので断念し、メソッド内で随時NSUserDefaultsを呼び出す形に。


#import <Foundation/Foundation.h>
#import "Define.h"
@class AWDefaultValues;

@interface AWUserDefaultsDriver : NSObject {
}
+(id)userDefaultsDriver;
@end
