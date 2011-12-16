//
//  StatusManager.m
//  WWYRPG
//
//  Created by awaBook on 11/01/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "StatusManager.h"

@implementation StatusManager

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}

+(id)statusManager{
	return [[[StatusManager alloc]init]autorelease];
}

//Newゲーム開始時の為に、ステータスのdefault値を作成してNSDictionaryで返す
-(NSDictionary*)getDefaultPlayerStatus{
	NSDictionary* outputDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"hero",@"charaKey",//各キャラにつき一意のKey。ストーリー上登場するパーティキャラ全てについて一意となるように。
                                      @"001",@"charaType",//キャラの外見。("0xx":プレイヤー、 "1xx":NPC)
                                      @"001",@"job",//パーティの職業。数字によってキャラのタイプも定義する。("0xx":プレイヤー、 "1xx":NPC)
                                      //@"ななし",@"name",
                                      [NSNumber numberWithInt:1],@"lv",
                                      [NSNumber numberWithInt:0],@"ex",
//                                      [NSNumber numberWithInt:9],@"lv",
//                                      [NSNumber numberWithInt:5000],@"ex",
                                      nil];
	return outputDictionary;
}

#pragma mark -
#pragma mark プレイヤーのステータスを返す
//全てのステータスをNSArrayで返す
-(NSArray*)getPlayerStatus{
    AWUserDefaultsDriver* userDefaultsDriver = [AWUserDefaultsDriver userDefaultsDriver];    
	NSArray* playerStatusArray = [userDefaultsDriver dictionaryForKey:@"playerStatus"];
    //何か整形することがあればここで
    //....
	return playerStatusArray;
}

//プレイヤーの整数パラメーターを返す。
-(int)getIntegerParameterOfPlayerStatus:(NSString*)paramName{
    NSDictionary* playerStatus = [self getPlayerStatus];
    return [[playerStatus objectForKey:paramName]intValue];
}
//プレイヤーの文字列パラメーターを返す。
-(NSString*)getStringParameterOfPlayerStatus:(NSString*)paramName{
    NSDictionary* playerStatus = [self getPlayerStatus];
    if(![[playerStatus objectForKey:paramName]isKindOfClass:[NSString class]]) {
        return nil;
    }
    return [playerStatus objectForKey:paramName];
}
//プレイヤーの配列パラメーターを返す。
-(NSArray*)getArrayParameterOfPlayerStatus:(NSString*)paramName{
    NSDictionary* playerStatus = [self getPlayerStatus];
    if(![[playerStatus objectForKey:paramName]isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return [playerStatus objectForKey:paramName];
}
//プレイヤーの辞書パラメーターを返す。
-(NSDictionary*)getDictionaryParameterOfPlayerStatus:(NSString*)paramName{
    NSDictionary* playerStatus = [self getPlayerStatus];
    if(![[playerStatus objectForKey:paramName]isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [playerStatus objectForKey:paramName];
}

#pragma mark -
#pragma mark ステータスのセット
//プレイヤーのステータスをセットする
-(void)setPlayerStatus:(NSDictionary*)status{
	[[AWUserDefaultsDriver userDefaultsDriver] setObject:status forKey:@"playerStatus"];
}
//プレイヤーのパラメーターをセットする。
-(void)setParameter:(NSString*)paramName paramObject:(id)paramObject{
	NSMutableDictionary* status = [NSMutableDictionary dictionaryWithDictionary:[self getPlayerStatus]];
	[status setObject:paramObject forKey:paramName];
	[self setPlayerStatus:status];
}
//プレイヤーのパラメーターを消去する。
-(void)clearParameter:(NSString*)paramName{
	NSMutableDictionary* status = [NSMutableDictionary dictionaryWithDictionary:[self getPlayerStatus]];
    [status removeObjectForKey:paramName];
	[self setPlayerStatus:status];
}
//プレイヤーの整数パラメーターをセットする。
-(void)setPlayerIntegerParameter:(NSString*)paramName value:(int)value{
    if (value <= 0) value = 0;//負の値は受け付けないようにしておく。0以下にはならない。
	NSMutableDictionary* status = [NSMutableDictionary dictionaryWithDictionary:[self getPlayerStatus]];
	[status setObject:[NSNumber numberWithInt:value] forKey:paramName];
	[self setPlayerStatus:status];
}
//プレイヤーの整数パラメーターをchangeValue分変化させる。
-(void)changeIntegerParameter:(NSString*)paramName changeValue:(int)value{
	NSMutableDictionary* status = [NSMutableDictionary dictionaryWithDictionary:[self getPlayerStatus]];
	int oldValue = [[status objectForKey:paramName]intValue];
    int newValue = oldValue + value;
    if (newValue <= 0) newValue = 0;//負の値は受け付けないようにしておく。
	[status setObject:[NSNumber numberWithInt:newValue] forKey:paramName];
	[self setPlayerStatus:status];
}

#pragma mark -
#pragma mark 経験値、レベル関係


//次のレベルまでの必要経験値を返す。有効な値じゃなければ0を返す。
-(int)getRequireExAtNextLevel{
    int ex_ = [self getIntegerParameterOfPlayerStatus:@"ex"];
    int level = [self getIntegerParameterOfPlayerStatus:@"lv"];
    
    int next_level_require_ex = [[AWBuiltInValuesManager builtInValuesManager]getRequireExAtLevel:level+1];
    
    int outputEx = next_level_require_ex - ex_;
    if (outputEx < 0 || level < 1) outputEx = 0;
    return outputEx;
}

//経験値をプラスし、レベルアップしたらYESを返す
-(BOOL)levelUpWithGainEX:(int)ex{
    BOOL levelUP = NO;
    
    //経験値をプラス
    [self changeIntegerParameter:@"ex" changeValue:ex];
    int ex_ = [self getIntegerParameterOfPlayerStatus:@"ex"];
    int level = [self getIntegerParameterOfPlayerStatus:@"lv"];
    
    //次のレベルの必要経験値を取得
    int next_level_require_ex = [[AWBuiltInValuesManager builtInValuesManager]getRequireExAtLevel:level+1];
    
    //経験値が次のレベルに達していれば
    if (next_level_require_ex > 0 && ex_ >= next_level_require_ex) {
        //レベルをプラス
        [self changeIntegerParameter:@"lv" changeValue:1];
        levelUP = YES;
    }else{
        levelUP = NO;
    }
    return levelUP;
}

#pragma mark -
#pragma mark 名前、称号
//なまえを得る
-(NSString*)getName{
    NSString *name = [[AWUserDefaultsDriver userDefaultsDriver]stringForKey:@"twitter_username"];
    if(!name) name = NSLocalizedString(@"nameless", @"");
    return name;
}
//現在の称号を得る
-(NSString*)getTitle{
    int lv = [self getIntegerParameterOfPlayerStatus:@"lv"];
    NSString *title = [[AWBuiltInValuesManager builtInValuesManager]getTitleAtLevel:lv];
    return title;
}

@end
