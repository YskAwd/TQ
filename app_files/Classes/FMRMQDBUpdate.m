//
//  FMRMQDBUpdate.m
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
////普通のqueryStringでUpdateする場合のみ使える。NSStringを何個も引数にとるUpdate文の指定の仕方には対応してない。
/*参考：DBへのquerystringの生成の例
 
 FMRMQDBUpdate* updateDB = [[FMRMQDBUpdate alloc]init];
 
 NSString* queryStr = SQL文
 
 //DBへ反映
 [updateDB upDateDBWithQueryString:queryStr];
 
 //インスタンスをリリース
 [updateDB release];
*/ 

#import "FMRMQDBUpdate.h"


@implementation FMRMQDBUpdate

-(BOOL)upDateDBWithQueryString:(NSString*)QueryString{//普通のqueryStringでUpdateする場合。
	BOOL update_complete = NO;
	queryString = [[NSString alloc]initWithString:QueryString];//引数でもらったqueryをコピー。
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
	FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //return 0;
    }else{
		
		[db setShouldCacheStatements:YES];
		
		[db beginTransaction];
		
		update_complete = [db executeUpdate:queryString];	
		
		[db commit];
		[db close];
		[queryString release];
	}
	return update_complete;
}

-(int)insertDBWithQueryString:(NSString*)QueryString{//インサートして、そのIDを取得。インサートに失敗したら0を返す。
    int lastInsertRowId = 0;
	queryString = [[NSString alloc]initWithString:QueryString];//引数でもらったqueryをコピー。
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
	FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //return 0;
    }else{
		
		[db setShouldCacheStatements:YES];
		
		[db beginTransaction];
		
		if([db executeUpdate:queryString]) lastInsertRowId = (int)[db lastInsertRowId];
        //NSLog(@"lastInsertRowId:%d",lastInsertRowId);
        
		[db commit];
		[db close];
		[queryString release];
	}
	return lastInsertRowId;
}

- (void)dealloc {
if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	[super dealloc];
}

@end
