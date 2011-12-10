//
//  AWBuiltInValuesManager.m
//  WWY2
//
//  Created by locolocode on 11/09/08.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AWBuiltInValuesManager.h"

@implementation AWBuiltInValuesManager
# pragma mark -
# pragma mark 生成、破棄
- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+(id)builtInValuesManager{
	return [[[AWBuiltInValuesManager alloc]init]autorelease];
}

# pragma mark -
# pragma mark レベル関係
//指定レベルのBuiltIn値をDictionaryで返す。
-(NSDictionary*)getBuiltInValuesAtLevel:(int)level{
    NSDictionary* builtInValuesAtLevel = nil;
    NSArray *builtInLevelsArray = [[AWBuiltInValuesFromCSV builtInValuesFromCSV]getBuiltInLevelsArray];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"lv = %d",level];
    NSArray* filterdKeys = [builtInLevelsArray filteredArrayUsingPredicate:predicate];
    if ([filterdKeys count] > 0) {
        builtInValuesAtLevel = [filterdKeys objectAtIndex:0];
    }
    return builtInValuesAtLevel;
}
//指定したレベルの必要経験値を返す。取得できなければ0を返す。
-(int)getRequireExAtLevel:(int)level{
    int level_require_ex = 0;
    NSDictionary *levelDict = [self getBuiltInValuesAtLevel:level];
    if (levelDict) {
        level_require_ex = [[levelDict objectForKey:@"require_ex"]intValue];
    }
    return level_require_ex;
}
//指定したレベルの獲得経験値をランダマイズして返す。有効な値じゃなければ0を返す。
-(int)getGainExAtLevel:(int)level{
    int gain_ex = 0;
    NSDictionary *levelDict = [self getBuiltInValuesAtLevel:level];
    if (levelDict) {
        gain_ex = [[levelDict objectForKey:@"gain_ex"]intValue];
    }
    //ランダマイズ　未実装
    gain_ex = [AWUtility randomizedInteger:gain_ex withRate:0.2f];
    return gain_ex;
}
//指定したレベルの称号（title）を返す。取得できなければnilを返す。
-(NSString*)getTitleAtLevel:(int)level{
    NSString* title = nil;
    NSDictionary *levelDict = [self getBuiltInValuesAtLevel:level];
    if (levelDict && [[levelDict objectForKey:@"title"]isKindOfClass:[NSString class]]) {
        title = [levelDict objectForKey:@"title"];
    }
    return title;
}
# pragma mark -
# pragma mark モンスターの名前関係
//enemyImageIdをもとに、Built-Inのモンスター名を返す
-(NSString*)getBuiltInMonsterNameWithImageId:(int)enemyImageId{
    NSString* outputStr = nil;
    NSArray *builtInMonsterNames = [[AWBuiltInValuesFromCSV builtInValuesFromCSV]getBuiltInMonsterNamesArray];
    NSString* nameKey = [AWUtility nameKeyFromUserLanguage];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ID = %d",enemyImageId];
    NSArray* filterdArray = [builtInMonsterNames filteredArrayUsingPredicate:predicate];
    if ([filterdArray count] > 0) {
        outputStr = [[filterdArray objectAtIndex:0]objectForKey:nameKey];
    }
    return outputStr;
}
//引数の名前がBuilt-In_MonsterNamesの中にあるかどうかを返す
-(BOOL)isExistsBuiltInMonsterNames:(NSString*)monsterName{
    NSArray *builtInMonsterNames = [[AWBuiltInValuesFromCSV builtInValuesFromCSV]getBuiltInMonsterNamesArray];
    NSString* nameKey = [AWUtility nameKeyFromUserLanguage];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"'%@' LIKE '%@'",nameKey,monsterName];
    NSArray* filterdArray = [builtInMonsterNames filteredArrayUsingPredicate:predicate];
    if ([filterdArray count] > 0) {
        return YES;
    }
    return NO;
}

@end
