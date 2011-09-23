//
//  AWDefaultValues.h
//  LocationTweet
//
//  Created by AWorkStation on 10/12/13.
//  Copyright 2010 Japan. All rights reserved.
//
//NSMutableDictionaryのサブクラスにしようと思っていたが、基本メソッドのオーバーライドが必要だそうなので断念し、インスタンス変数としてNSMutableDictionaryを持つ形に。

#import <Foundation/Foundation.h>
#import "Define.h"
#import "StatusManager.h"
@interface AWDefaultValues : NSObject {
	
	NSMutableDictionary *_dictionary;

}

@end
