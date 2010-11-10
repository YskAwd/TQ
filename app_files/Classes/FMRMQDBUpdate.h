//
//  FMRMQDBUpdate.h
//  RMQuest2
//
//  Created by awaBook on 09/02/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//	DBへの値反映に使うクラス

#import <Foundation/Foundation.h>

//SQLite用
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface FMRMQDBUpdate : NSObject {
	NSString* queryString;
}
-(BOOL)upDateDBWithQueryString:(NSString*)QueryString;
@end
