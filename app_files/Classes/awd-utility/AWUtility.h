//
//  AWUtility.h
//  LocationTweet
//
//  Created by AWorkStation on 10/12/16.
//  Copyright 2010 Japan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

@interface AWUtility : NSObject {

}
//日本語名か英語名どちらを使うか判定するため、ユーザーが使っている言語によって@"name_ja"と@"name_en"どちらかの文字列を返す。
+(NSString*)nameKeyFromUserLanguage;	
//ユーザーが使っている言語によって@"ja"と@"en"どちらかの文字列を返す。
+(NSString*)langKeyFromUserLanguage;

//アルファベットを1→A 2→B という具合に 整数で指定して返す。
+(NSString*)alphabetFromInt:(int)alphabetNum isBigLetter:(BOOL)isBigLetter;

//NSDateをNSStringに決まったフォーマットで変換する。
-(NSString*)stringFromDate:(NSDate*)date;

//NSStringをNSDateに決まったフォーマットで変換する。
-(NSDate*)dateFromString:(NSString*)string;

//NSDateのhour、minutes,secondsの合計を秒に変換する。day以上やmiliseconds以下は反映しない
-(float)secondsFrom_HH_mm_SS_OfDate:(NSDate*)date;

@end
