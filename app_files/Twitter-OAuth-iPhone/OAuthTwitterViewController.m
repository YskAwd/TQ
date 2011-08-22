//
//  OAuthTwitterViewController.m
//  OAuthTwitterDemo
//
//  Created by Ben Gottlieb on 7/24/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import "OAuthTwitterViewController.h"
#import "SA_OAuthTwitterEngine.h"


//#define kOAuthConsumerKey				@"7bdtTEnyVoBbKfHfp1VAA"		//REPLACE ME
//#define kOAuthConsumerSecret			@"9fIvJyfCFxcIvenIdSxdwXSxUVg9NcxeCMPlFokXPI"		//REPLACE ME

@implementation OAuthTwitterViewController

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	[_engine release];
	[_controller release];
    [super dealloc];
}

-(id)initWithViewFrame:(CGRect)frame delegate:(id)delegate{
	if(self = [self initWithDelegate:delegate]){
		self.view.frame = frame;
		//self.view.backgroundColor = [UIColor grayColor];
		self.view.hidden = YES;//こうしとかないとうまく行かん。
		self.view.opaque = YES;
	}
	return self;
}

-(id)initWithDelegate:(id)delegate{
	if(self = [super init]){
		_delegate = delegate;
		/*
		//temporary
		NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
		[defaults removeObjectForKey:@"authData"];
		//temporary end
		*/
		if (!_engine) {
			_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
			_engine.consumerKey = kOAuthConsumerKey;
			_engine.consumerSecret = kOAuthConsumerSecret;
			
			_controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
			[_controller retain];
		}
	}
	return self;
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
//ツイッターアカウントのトークンStrの格納／引出　関係
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject: data forKey: @"authData"];
	
	//defaultsにusernameを保存する(added by awazu)
	[defaults setObject:username forKey: @"twitter_username"];
	NSLog(@"SET USER DAFAULT");
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {

	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenticated for %@", username);
	
	//Twitterにつぶやく
	//[_engine sendUpdate: [NSString stringWithFormat: @"Twitter API test from TaskQuest. %@", [NSDate date]]];
	
	/*NSString *postStr = [NSString stringWithFormat:@"%@%@%@",
						 NSLocalizedString(@"hero",@""),username,NSLocalizedString(@"twitt_post_when_Authenticated",@"")];
	
	[self postTweet:postStr];*/
	//[_engine sendUpdate:postStr];
	
	[_delegate twitterOAuthSuccess];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
	[_delegate twitterOAuthFailed];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
	[_delegate twitterOAuthCanceled];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}



//=============================================================================================================================
#pragma mark ViewController Stuff



//=============================================================================================================================
#pragma mark -
#pragma mark オーサライズ関係
-(void)setUpOAuth{
	[self setUpOAuthWithAnotherAccountOrNot:NO];
}

-(void)setUpOAuthWithAnotherAccountOrNot:(BOOL)AnotherAccount{
	
	//すでに承認情報があるならば、initメソッドで、_controllerにはnilが代入されている。
	
	if(AnotherAccount) {//別アカウントでの承認依頼ならcontrollerを作り直す。
		if (_controller) [_controller autorelease];
		_controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngineAtAnotherAccount: _engine delegate: self];
		[_controller retain];
	}
	
	if (_controller){ //承認がまだか、別アカウントでの承認依頼なら
		[self presentModalViewController: _controller animated: YES];
	}else {
		NSLog(@"alreadyAuthenticated");
		[_delegate twitterOAuthAlreadyAuthenticated];
	}
}

//=============================================================================================================================
#pragma mark -
#pragma mark ツイートのpost関係
//twitterにつぶやく。ジオタグ指定して。
-(BOOL)postTweet:(NSString*)postStr withLat:(NSString*)lat lng:(NSString*)lng{
	
	//現在時を取得。
	NSDate *nowDate = [NSDate date];
	NSDateFormatter *dateFotmatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFotmatter setDateStyle:NSDateFormatterShortStyle];
	[dateFotmatter setTimeStyle:NSDateFormatterShortStyle];
	/*NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFotmatter setLocale:locale];*/
	NSString *nowDate_str= [dateFotmatter stringFromDate:nowDate];
	
	//つぶやくStringの後ろに現在時、ハッシュタグをつける。
	NSString *postString = [NSString stringWithFormat:@"%@ %@ %@",postStr,nowDate_str,TWITTER_HASH_TAG];
	//NSString *postString = [NSString stringWithFormat:@"%@ %@",postStr,nowDate_str];
	
	NSString *tweetedOrNot;//NSLogで実際にTweetしたかどうかを見るためのもの。NSLogでのみ末尾に付く。
	
	if(!IS_TEST || TWEET_ENABLE_AT_TEST){
		//[_engine sendUpdate:postString];
		[_engine sendUpdate:postString withLat:lat lng:lng];
		tweetedOrNot = @"(tweeted)";
	}else{
		tweetedOrNot = @"(not tweeted)";
	}
	
	NSLog(@"%@ %@",postString,tweetedOrNot);
	
	return YES;
}

//twitterにつぶやく。ジオタグなしで。
-(BOOL)postTweet:(NSString*)postStr{
    [self postTweet:postStr withLat:nil lng:nil];
    return YES;
}

#pragma mark -
#pragma mark twitterにlocatioを設定。
//twitterにlocatioを設定。
-(BOOL)setLocation:(NSString*)location{
	if(_engine) [_engine setLocation:location];
	return YES;
}

@end
