//
//  AWBuiltInValuesFromCSV.m
//  WWYRPG
//
//  Created by AWorkStation on 11/04/30.
//  Copyright 2011 Japan. All rights reserved.
//

#import "AWBuiltInValuesFromCSV.h"

@implementation AWBuiltInValuesFromCSV

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}

+(id)builtInValuesFromCSV{
	return [[[AWBuiltInValuesFromCSV alloc]init]autorelease];
}

//レベルに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInLevelsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Levels_1.1" ofType:@"csv"];
    if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}

/*
//モンスターデータに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInMonstersArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Monsters_1.0" ofType:@"csv"];
    if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//アイテムデータに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInItemsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Items_1.0" ofType:@"csv"];
    if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//まほうデータに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInMagicsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Magics_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//モンスターのアクションパターンに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInMonsterActionsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Monster_Actions_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//職業に関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInJobsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Jobs_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//ランドマークに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInLandmarksArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_Landmarks_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//フィールドマップのアクションに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInFMapActionsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_FMap_Actions_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
//フィールドマップのイベントに関するUserDefaultsのデフォルト値をタブ区切りCSVファイルから取り出して返す。
-(NSArray*)getBuiltInFMapEventsArray{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Built-In_FMap_Events_1.0" ofType:@"csv"];
	if (!path) return nil;
    else return [self getBuiltInDataFromCSV:path];
}
*/

//pathで指定したCSVからNSArrayを生成。
-(NSArray*)getBuiltInDataFromCSV:(NSString*)path{
    NSMutableArray* outputArray = [[NSMutableArray alloc]init];
    
    NSString* strFromCSV = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray* rows = [strFromCSV componentsSeparatedByString:@"\n"];
    NSArray* labels = [[rows objectAtIndex:0] componentsSeparatedByString:@"\t"];
    NSArray* types = [[rows objectAtIndex:1] componentsSeparatedByString:@"\t"];
    
    for (int i=2; i<[rows count]; i++) {
        NSArray* columns = [[rows objectAtIndex:i] componentsSeparatedByString:@"\t"];
        NSMutableDictionary *columnsDict = [NSMutableDictionary dictionaryWithCapacity:0];
        for (int j=0; j<[columns count]; j++) {
            //typeで、どの型で格納するか判断する。（型を分けていれないと、配列をフィルタリングするときに問い合わせ言語を使えない。）
            NSString* label = [labels objectAtIndex:j];
            NSString* type = [types objectAtIndex:j];
            
            //NSNumber型(int)で入れるもの
            if([type isEqualToString:@"INT"]) {
                [columnsDict setValue:[NSNumber numberWithInt:[[columns objectAtIndex:j]intValue]] forKey:label];
            }
            //NSNumber型(float)で入れるもの
            else if([type isEqualToString:@"FLOAT"]) {
                [columnsDict setValue:[NSNumber numberWithFloat:[[columns objectAtIndex:j]floatValue]] forKey:label];
            }
            //NSNumber型(Boolearn)で入れるもの
            else if([type isEqualToString:@"BOOLEAN"] || [type isEqualToString:@"BOOL"]) {
                [columnsDict setValue:[NSNumber numberWithBool:[[columns objectAtIndex:j]boolValue]] forKey:label];
            }
            //その他、NSString型で入れるもの
            else{
                [columnsDict setValue:[columns objectAtIndex:j] forKey:label];
            }
        }
        [outputArray addObject:columnsDict];
    }
    //NSLog(@"outputArray:%@",outputArray);
    return outputArray;
}

@end
