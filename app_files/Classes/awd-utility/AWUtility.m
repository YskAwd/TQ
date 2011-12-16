//
//  AWUtility.m
//  LocationTweet
//
//  Created by AWorkStation on 10/12/16.
//  Copyright 2010 Japan. All rights reserved.
//

#import "AWUtility.h"


@implementation AWUtility

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [super dealloc];
}

+(id)aWUtility{
	return [[[AWUtility alloc]init]autorelease];
}

#pragma mark -
#pragma mark ローカライゼーション関係
//日本語名か英語名どちらを使うか判定するため、
//ユーザーが使っている言語によって@"name_ja"と@"name_en"どちらかの文字列を返す。
+(NSString*)nameKeyFromUserLanguage{	
	NSString* nameKey;
	//ユーザの言語を判定
	NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	if([currentLanguage isEqualToString:@"ja"]){//ユーザの言語環境が日本語なら
		nameKey = @"name_ja";
	}else{//日本語以外なら
		nameKey = @"name_en";
	}
	return nameKey;	
}
//ユーザーが使っている言語によって@"ja"と@"en"どちらかの文字列を返す。
+(NSString*)langKeyFromUserLanguage{	
	NSString* nameKey;
	//ユーザの言語を判定
	NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	if([currentLanguage isEqualToString:@"ja"]){//ユーザの言語環境が日本語なら
		nameKey = @"ja";
	}else{//日本語以外なら
		nameKey = @"en";
	}
	return nameKey;	
}

#pragma mark -
#pragma mark 文字列関係
//アルファベットを1→A 2→B という具合に 整数で指定して返す。
+(NSString*)alphabetFromInt:(int)alphabetNum isBigLetter:(BOOL)isBigLetter{	
    NSString* letter = nil;
    if(alphabetNum > 0){
        if(!isBigLetter){
            NSArray* letters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
            if(alphabetNum <= [letters count]){
                letter = [letters objectAtIndex:alphabetNum-1];
            }
        }else{
            NSArray* letters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
            if(alphabetNum <= [letters count]){
                letter = [letters objectAtIndex:alphabetNum-1];
            }
        }
	}
	return letter;	
}

#pragma mark -
#pragma mark 日付関係
//NSDateをNSStringに決まったフォーマットで変換する。
-(NSString*)stringFromDate:(NSDate*)date{
	//フォーマッター
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	//「en_US」ロケールでString化
	NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFormatter setLocale:locale];
	NSString *outputTxt = [dateFormatter stringFromDate:date];
	return outputTxt;
}
//NSStringをNSDateに決まったフォーマットで変換する。
-(NSDate*)dateFromString:(NSString*)string{
	//フォーマッター
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	//「en_US」ロケールのStringからDate化
	NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFormatter setLocale:locale];
	NSDate *outputDate = [dateFormatter dateFromString:string];
	return outputDate;
}
//NSDateのhour、minutes,secondsの合計を秒に変換する。day以上やmiliseconds以下は反映しない
-(float)secondsFrom_HH_mm_SS_OfDate:(NSDate*)date{
	NSCalendar* calender = [[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar]autorelease];
	NSUInteger flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [calender components:flags fromDate:date];
	int hour = [components hour];
	int minute = [components minute];
	int second = [components second];
	//NSLog(@"hour:%d minute:%d second:%d ", hour, minute, second);
	float tweetIntervalSeconds = ((hour*60.0 + minute)*60.0) + second ;
	//NSLog(@"tweetIntervalMinutes:%f ", tweetIntervalMinutes);
	return tweetIntervalSeconds;
}

#pragma mark -
#pragma mark 乱数関係
#pragma mark ○から○までのランダムな整数を返す
+(int)randomIntegerFrom:(int)from to:(int)to{
	int random = rand() % to + from;
	return random;
}
#pragma mark -○から○までのランダムな整数を返す
+(int)randomIntegerWithAbsoluteValue:(int)absoluteValue{
	int output = 0;
	if(absoluteValue < 0) absoluteValue *= -1;
	if(absoluteValue != 0) {
		output = rand() % (absoluteValue*2) - absoluteValue;
	}
	return output;
}
#pragma mark inputをランダマイズした整数を返す。ランダマイズの割合をrate(0〜1の少数)で指定。
+(int)randomizedInteger:(int)input withRate:(double)rate{
	int val = 0;//増減値
	if(rate < 0.0) rate = 0.0;
	if(rate > 1.0) rate = 1.0;
	if(rate != 0.0){
		val = [self randomIntegerWithAbsoluteValue:(int)(input*rate/2)];
	}
	return input + val;
}
#pragma mark 確率付きでランダムに選ぶ
//引数には、NSNumberに相対的な確率を整数でいれた配列をとる。返り値は、選択された配列の番号。
+(int)randomSelectionWithOdds:(NSArray*)arrayContainOdds{
	int selectedNum = 0;
	//まず相対的な確率の合計を出す
	int oddsTotal = 0;
	for (NSNumber* odds in arrayContainOdds){
		oddsTotal += abs([odds intValue]);
	}
    //合計が0ならば1にする。（0では割れないので）
    if(oddsTotal==0) oddsTotal = 1;
    
	//1から「相対的な確率の合計」までの範囲の乱数を求める。
	int random = ( rand() % oddsTotal ) + 1;

	//引数の配列に入っている「相対的な確率」をひとつずつ足していき、上の乱数がどの範囲に入っているか求める。乱数が入っているときの配列番号が求める値。
	int k = 0;
	for (int i=0; i<[arrayContainOdds count]; i++){
		if (k <= random && random <= k+[[arrayContainOdds objectAtIndex:i]intValue]) {
			selectedNum = i;
			break;
		}
		k += [[arrayContainOdds objectAtIndex:i]intValue];
	}
	return selectedNum;
}



@end
