//
//  TwitterManager.m
//  WWY2
//
//  Created by awaBook on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TwitterManager.h"


@implementation TwitterManager
@synthesize twitter_name = twitter_name_;

- (void)dealloc {
	NSLog(@"TwitterManager---------------------Dealloc!!");
	if(!oAuthTwitterViewController_) [oAuthTwitterViewController_ release];
	if(twitter_name_) [twitter_name_ release];
	[delegate_ release];
    [super dealloc];
}

-(id)initWithDelegate:(id)delegate{
	if(self=[super init]){
		[delegate retain];
		delegate_ = delegate;
		//oAuthTwitterViewController_はいろいろViewの遷移まで実装されてるため、addSubviewすると
		//releaseのタイミング等がややこしい。なのでinitだけして使う。
		if(!oAuthTwitterViewController_) {
			oAuthTwitterViewController_ = [[OAuthTwitterViewController alloc]initWithDelegate:self];
		}
		
		WWYHelper_DB *helper_DB = [[WWYHelper_DB alloc]init];
		twitter_name_ = [helper_DB getTwitterUsername];
		[helper_DB release];
	}
	return self;
}

//つぶやきをポストする
-(BOOL)postTweet:(NSString*)tweetStr{	
	BOOL success = NO;
	success = [oAuthTwitterViewController_ postTweet:tweetStr];
	return success;
}

@end
