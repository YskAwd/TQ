//
//  AWBuiltInValuesFromCSV.h
//  WWYRPG
//
//  Created by AWorkStation on 11/04/30.
//  Copyright 2011 Japan. All rights reserved.
//
//BuiltInの値をCSVから読み込むためのクラス。ゲーム進行してもかわることのないマスタデータ系を扱う。

#import <Foundation/Foundation.h>
#import "Define.h"

@interface AWBuiltInValuesFromCSV : NSObject {
}

+(id)builtInValuesFromCSV;

//pathで指定したCSVからNSArrayを生成。
-(NSArray*)getBuiltInDataFromCSV:(NSString*)path;

@end
