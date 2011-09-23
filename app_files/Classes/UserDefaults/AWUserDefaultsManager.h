//
//  AWUserDefaultsManager.h
//  LocationTweet
//
//  Created by AWorkStation on 10/12/17.
//  Copyright 2010 Japan. All rights reserved.
//
//UserDefaultsのデータを、各クラスが利用しやすいように取得・保存する為のクラス。
//プレイヤーのステータスや戦闘中のモンスターのステータスは、StatusManager、MonsterStatusManagerを使うこと。

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Define.h"
#import "AWUserDefaultsDriver.h"

@interface AWUserDefaultsManager : NSObject {

}
+(id)userDefaultsManager;
@end
