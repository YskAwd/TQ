//
//  FMRMQDBSelect.m
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "FMRMQDBSelect.h"
#import "FMResultSet.h"
#import "FMDatabase.h"

/*
 このクラスを使うには、#import "FMResultSet.h"をする必要あり。
*/
/*//参考：
 //以下、取得の例:
 //DB接続
FMRMQDBSelect* DBSelect= [[FMRMQDBSelect alloc]init];
NSString*  queryString = @"SELECT * FROM player WHERE id=0";
FMResultSet* rs = [DBSelect selectFromDBWithQueryString:queryString];
 
 //rsからの値取得:
 while ([rs next]) {
	 //rsから値を取得
	 NSNumber* id_ =[NSNumber numberWithInt:[rs intForColumn:@"id"]];
	 NSString* name = [rs stringForColumn:@"name"];
	 NSNumber* hp =[NSNumber numberWithInt:[rs intForColumn:@"hp"]];
	 NSNumber* mp =[NSNumber numberWithInt:[rs intForColumn:@"mp"]];
	 NSNumber* pw =[NSNumber numberWithInt:[rs intForColumn:@"pw"]];
	 NSNumber* quickness =[NSNumber numberWithInt:[rs intForColumn:@"quickness"]];
	 NSNumber* strength =[NSNumber numberWithInt:[rs intForColumn:@"strength"]];
	 NSNumber* cleverness =[NSNumber numberWithInt:[rs intForColumn:@"cleverness"]];
	 NSNumber* luck =[NSNumber numberWithInt:[rs intForColumn:@"luck"]];
	 NSNumber* lv =[NSNumber numberWithInt:[rs intForColumn:@"lv"]];
	 NSNumber* gold =[NSNumber numberWithInt:[rs intForColumn:@"gold"]];
	 NSNumber* exp =[NSNumber numberWithInt:[rs intForColumn:@"exp"]];
	 //player配列にいれていく
	 [player replaceObjectAtIndex:0 withObject:id_];
	 [player replaceObjectAtIndex:1 withObject:name];
	 [player replaceObjectAtIndex:2 withObject:hp];
	 [player replaceObjectAtIndex:3 withObject:mp];
	 [player replaceObjectAtIndex:4 withObject:pw];
	 [player replaceObjectAtIndex:5 withObject:quickness];
	 [player replaceObjectAtIndex:6 withObject:strength];
	 [player replaceObjectAtIndex:7 withObject:cleverness];
	 [player replaceObjectAtIndex:8 withObject:luck];
	 [player replaceObjectAtIndex:9 withObject:lv];
	 [player replaceObjectAtIndex:10 withObject:gold];
	 [player replaceObjectAtIndex:11 withObject:exp];
	 
	 NSLog(@"%d %@ %d ",
	 [rs intForColumn:@"hp"],
	 [rs stringForColumn:@"name"],
	 [rs intForColumn:@"id"]);
 }
 //必ずインスタンスをreleaseする。rsはクラスの方でreleaseしてるようで、releaseしなくてよい。
[DBSelect release];
*/




@implementation FMRMQDBSelect

-(FMResultSet*)selectFromDBWithQueryString:(NSString*)QueryString{
	//queryString = QueryString ;
	queryString = [NSString stringWithString:QueryString] ;
	//DBファイルのPathを取得
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"db.sqlite"];
	BOOL success = [fileManager fileExistsAtPath:writableDBPath];
	if(!success){ 
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	}
	if(!success){
		NSAssert1(0, @"failed to create writable db file with message '%@'.", [error localizedDescription]);
	}
	
	//実際にSqliteを操作する
	db = [FMDatabase databaseWithPath:writableDBPath];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //return 0;
    }else{
		
		[db setShouldCacheStatements:YES];
		
		rs = [db executeQuery:queryString];
		
	
		//[rs close];
		//[db close];
	}
	return rs;
}

- (void)dealloc {
    [rs close];
	[db close];
	
	NSLog(@"FMRMQDBSelsect---------dealloc!");
    [super dealloc];
}

@end
