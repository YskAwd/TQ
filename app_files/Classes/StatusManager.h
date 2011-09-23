//
//  StatusManager.h
//  WWYRPG
//
//  Created by awaBook on 11/01/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//パーティーのステータスに関連する処理を行う。
//プレイヤーの持っているアイテム等も。
//Built-Inデータベースからアイテム単体を取得するとき等はUserDefaultsManagerの方をつかう。
//たぶんバグあり。バトル関係のメソッドはNPCを除いたキャラをorderパラメータ順に並べて返すので、orderパラメータと返す配列のキー番号とは一致しない。
//配列のキー番号で取得/設定するのではなく、orderパラメータをキーに取得／設定するよう改良すればOK。【未実装】
//NPCキャラが出てこないうちはバグが出ない。
//今後MonsterStatusManagerと各メソッド名を同じにする？

#import <Foundation/Foundation.h>
#import "AWUserDefaultsManager.h"
#import "AWUserDefaultsDriver.h"
#import "AWBuiltInValuesFromCSV.h"
#import "AWBuiltInValuesManager.h"

@interface StatusManager : NSObject {

}
+(id)statusManager;
@end
