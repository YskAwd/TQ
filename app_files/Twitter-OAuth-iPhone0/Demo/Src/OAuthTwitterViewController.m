//
//  OAuthTwitterViewController.m
//  OAuthTwitterDemo
//
//  Created by Ben Gottlieb on 7/24/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import "OAuthTwitterViewController.h"
#import "SA_OAuthTwitterEngine.h"


#define kOAuthConsumerKey				@"7bdtTEnyVoBbKfHfp1VAA"		//REPLACE ME
#define kOAuthConsumerSecret			@"9fIvJyfCFxcIvenIdSxdwXSxUVg9NcxeCMPlFokXPI"		//REPLACE ME

@implementation OAuthTwitterViewController

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
		if (!_engine) {
			_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
			_engine.consumerKey = kOAuthConsumerKey;
			_engine.consumerSecret = kOAuthConsumerSecret;
			
			_controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
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
	[defaults synchronize];
	
	//DBにもusernameを保存する
	[_delegate twitterStoreUsernameOnDB:username];
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
	
	NSString *postStr = [NSString stringWithFormat:@"%@%@%@",
						 NSLocalizedString(@"hero",@""),username,NSLocalizedString(@"twitt_post_when_Authenticated",@"")];
	
	[self postTweet:postStr];
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
- (void)dealloc {
	NSLog(@"OAuthTwitterViewController----------dealloc!!!");
	[_engine release];
    [super dealloc];
}


//=============================================================================================================================
//オーサライズ関係
//- (void) viewDidAppear: (BOOL)animated {
-(void)setUpOAuth{
	[self setUpOAuthWithAnotherAccountOrNot:NO];
}

-(void)setUpOAuthWithAnotherAccountOrNot:(BOOL)AnotherAccount{
	
	//すでに承認情報があるならば、initメソッドで、_controllerにはnilが代入されている。
	
	if(AnotherAccount) {//別アカウントでの承認依頼なら、controllerを作り直す。
		_controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngineAtAnotherAccount: _engine delegate: self];
	}
	
	if (_controller){ //承認がまだか、別アカウントでの承認依頼なら
		[self presentModalViewController: _controller animated: YES];
	}else {
		NSLog(@"alreadyAuthenticated");
		[_delegate twitterOAuthAlreadyAuthenticated];
	}
}

//=============================================================================================================================
//ツイートのpost関係
//twitterにつぶやく。
-(BOOL)postTweet:(NSString*)postStr{
	
	//現在時を取得。
	NSDate *nowDate = [NSDate date];
	NSDateFormatter *dateFotmatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFotmatter setDateStyle:NSDateFormatterShortStyle];
	[dateFotmatter setTimeStyle:NSDateFormatterShortStyle];
	/*NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFotmatter setLocale:locale];*/
	NSString *nowDate_str= [dateFotmatter stringFromDate:nowDate];
	
	//つぶやくStringの後ろに現在時とハッシュタグをつける。
	NSString *postString = [NSString stringWithFormat:@"%@ %@ %@",postStr,nowDate_str,TWITTER_HASH_TAG];
	
	NSString *tweetedOrNot;//NSLogで実際にTweetしたかどうかを見るためのもの。NSLogでのみ末尾に付く。
	
	if(TWEET_ENABLE){
		[_engine sendUpdate:postString];
		tweetedOrNot = @"(tweeted)";
	}else{
		tweetedOrNot = @"(not tweeted)";
	}
	
	NSLog(@"%@ %@",postString,tweetedOrNot);
	
	return YES;
}

@end
