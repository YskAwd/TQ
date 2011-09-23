//
//  AWUserDefaultsDriver.m
//  LocationTweet
//
//  Created by AWorkStation on 10/12/13.
//  Copyright 2010 Japan. All rights reserved.
//

#import "AWUserDefaultsDriver.h"
#import "AWDefaultValues.h"

@implementation AWUserDefaultsDriver

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}
+(id)userDefaultsDriver{
	return [[[AWUserDefaultsDriver alloc]init]autorelease];
}

# pragma mark -
# pragma mark UserDefaultsに設定が存在しなかった場合にはAWDefaultValuesクラスで規定された値を返す。

- (NSArray *)arrayForKey:(NSString *)defaultName{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *output = [userDefaults arrayForKey:defaultName];
	if (!output) {
		id defaultValue = [[[[AWDefaultValues alloc]init]autorelease]valueForKey:defaultName];
		if([defaultValue isKindOfClass:[NSArray class]]){
			output = defaultValue;
			[userDefaults setObject:output forKey:defaultName]; 
		}
	}
	return output;
}
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *output = [userDefaults dictionaryForKey:defaultName];
	if (!output) {
		id defaultValue = [[[[AWDefaultValues alloc]init]autorelease]valueForKey:defaultName];
		if([defaultValue isKindOfClass:[NSDictionary class]]){
			output = defaultValue;
			[userDefaults setObject:output forKey:defaultName]; 
		}
	}
	return output;
}

- (NSString *)stringForKey:(NSString *)defaultName{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *output = [userDefaults stringForKey:defaultName];
	if (!output) {
		id defaultValue = [[[[AWDefaultValues alloc]init]autorelease]valueForKey:defaultName];
		if([defaultValue isKindOfClass:[NSString class]]){
			output = defaultValue;
			[userDefaults setObject:output forKey:defaultName]; 
		}
	}
	return output;
}

- (BOOL)boolForKey:(NSString *)defaultName{
	BOOL output;
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	//userDefaultsに格納されたBOOL値をvalueForKeyで取り出した場合には、"NO"が格納されていても「真」と評価されることを利用。
	if([userDefaults valueForKey:defaultName]){	//すでにuserDefaultsに格納されていれば、valueForKeyでBOOL値を取り出す。
		output = [userDefaults boolForKey:defaultName];
	} else  {//userDefaultsになければ、「AWDefaultValues」クラスのものを代入する。
		id defaultValue = [[[[AWDefaultValues alloc]init]autorelease]valueForKey:defaultName];
		if([defaultValue isKindOfClass:[NSNumber class]]){
			output = [defaultValue boolValue];
			[userDefaults setBool:output forKey:defaultName];
		}
	}
	return output;
}

- (NSInteger)integerForKey:(NSString *)defaultName{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger output;
	//integerForKeyでは、デフォルト値が格納されていない場合でも0が返ってきて、0が入ってる場合と区別がつかないので、valueForKeyの返り値でジャッジする。
	id jadge = [userDefaults valueForKey:defaultName];
	
	if (jadge) {
		output = [userDefaults integerForKey:defaultName];
	} else {
		id defaultValue = [[[[AWDefaultValues alloc]init]autorelease]valueForKey:defaultName];
		if([defaultValue isKindOfClass:[NSNumber class]]){
			output = [defaultValue intValue];
			[userDefaults setInteger:output forKey:defaultName];
		}
	}
	return output;
}

# pragma mark -
# pragma mark set系メソッド
- (void)setObject:(id)value forKey:(NSString *)defaultName {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:defaultName];
}

# pragma mark -
# pragma mark その他NSUserDefaultsメソッド
- (BOOL)synchronize{
	return [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)removeObjectForKey:(NSString *)defaultName{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultName];
}

@end
