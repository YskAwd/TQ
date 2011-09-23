//
//  NetworkConnectionManager.h
//  WWY2
//
//  Created by AWorkStation on 10/11/23.
//  Copyright 2010 Japan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "JSON.h"
@class URLConnectionGetter;

@interface NetworkConnectionManager : NSObject {
	URLConnectionGetter* _urlConnectionGetter;
	//NSMutableArray* _connectionManagerArray;
	NSMutableDictionary* _connectionManageDictionary;

}

@end
