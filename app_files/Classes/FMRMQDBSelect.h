//
//  FMRMQDBSelect.h
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//	DBからの値取得に使うクラス。

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
@class FMResultSet;
@class FMDatabase;

@interface FMRMQDBSelect : NSObject {
	FMDatabase* db;
	FMResultSet* rs;
	NSString* queryString;
}
-(FMResultSet*)selectFromDBWithQueryString:(NSString*)QueryString;
@end
