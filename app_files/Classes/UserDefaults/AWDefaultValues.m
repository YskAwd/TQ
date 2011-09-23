//
//  AWDefaultValues.m
//  LocationTweet
//
//  Created by AWorkStation on 10/12/13.
//  Copyright 2010 Japan. All rights reserved.
//

#import "AWDefaultValues.h"

@implementation AWDefaultValues

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(_dictionary) [_dictionary release];
    [super dealloc];
}

+(id)defaultValues{
	return [[[AWDefaultValues alloc]init]autorelease];
}

-(id)init{
	if(self = [super init]){
		if(NSLOG_REPORT_ENABLE) NSLog(@"AWDefaultValuesが生成。大量に生成されるなら注意。");
		
		_dictionary = [[NSMutableDictionary alloc]init];
		//UserDefaultsのデフォルト値を格納
		[_dictionary setObject:[[[NSBundle mainBundle]infoDictionary]objectForKey:(NSString*)kCFBundleVersionKey] forKey:@"AW_APP_VERSION"];
        [_dictionary setObject:[[StatusManager statusManager]getDefaultPlayerStatus] forKey:@"playerStatus"];

        
        /*
		[_dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"tweet_switch"];
		[_dictionary setObject:@"未設定" forKey:@"twitter_username"];
		[_dictionary setObject:@"" forKey:@"MC_storyFlag"];
		[_dictionary setObject:[NSNumber numberWithInt:0] forKey:@"MC_gMapFlag"];
		[_dictionary setObject:[NSNumber numberWithInt:0] forKey:@"MC_encounterFlag"];
		[_dictionary setObject:[NSNumber numberWithInt:0] forKey:@"MC_battleFlag"];
		[_dictionary setObject:[[StatusManager statusManager]getDefaultPartyStatus] forKey:@"partyStatus"];
        [_dictionary setObject:[NSNumber numberWithInt:0] forKey:@"money"];//パーティーの所持金
		[_dictionary setObject:[NSNumber numberWithInt:WWYWorldMode_local] forKey:@"worldMode"];        
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInMonstersArray] forKey:@"Built-In_Monsters"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInItemsArray] forKey:@"Built-In_Items"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInMagicsArray] forKey:@"Built-In_Magics"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInMonsterActionsArray] forKey:@"Built-In_Monster_Actions"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInJobsArray] forKey:@"Built-In_Jobs"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInLandmarksArray] forKey:@"Built-In_Landmarks"];
//        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInFMapsArray] forKey:@"Built-In_FMaps"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInFMapActionsArray] forKey:@"Built-In_FMap_Actions"];
        [_dictionary setObject:[[AWDefaultValuesFromCSV defaultValuesFromCSV]getBuiltInFMapEventsArray] forKey:@"Built-In_FMap_Events"];
        
		//...
		//memo 戦闘中のモンスターは、@"monsters_atBattle"のキーでNSArrayでuserDefaultsに格納する。
        */
        
	}
	return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey{
	[_dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey{
	[_dictionary removeObjectForKey:aKey];
}

- (NSUInteger)count{
	return [_dictionary count];
}
- (id)objectForKey:(id)aKey{
	return [_dictionary objectForKey:aKey];
}
- (id)valueForKey:(id)aKey{
	return [self objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [_dictionary keyEnumerator];
}

#pragma mark -
#pragma mark このクラスで定義しているデフォルト値の、全てのKeyStringをArrayで返す
-(NSArray*)allKeyStrings{
	return [_dictionary allKeys];
}

@end
