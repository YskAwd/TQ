//
//  TwitterManager.h
//  WWY2
//
//  Created by awaBook on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthTwitterViewController.h"
#import "WWYHelper_DB.h"
#import "Define.h"

@interface TwitterManager : NSObject {
	OAuthTwitterViewController *oAuthTwitterViewController_;
	id *delegate_;
	NSString* twitter_name_;

}

@property (readonly,assign) NSString* twitter_name;
@end
