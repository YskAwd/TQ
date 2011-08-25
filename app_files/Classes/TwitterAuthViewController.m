    //
//  TwitterAuthViewController.m
//  WWY2
//
//  Created by awaBook on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TwitterAuthViewController.h"


@implementation TwitterAuthViewController




- (void)dealloc {
	NSLog(@"TwitterAuthViewController---------------------Dealloc!!");
	[self sendReleaseToAuthTwitterView];
	[delegate_ release];
	if(yesOrNoCommandView_) [yesOrNoCommandView_ removeFromSuperview];[yesOrNoCommandView_ autorelease];
	if(liveView_)[liveView_ removeFromSuperview];[liveView_ release];
    [super dealloc];
}


-(id)initWithViewFrame:(CGRect)frame delegate:delegate{
	if(self= [super init]){
		[delegate retain];
		delegate_ = delegate;
		self.view.frame = frame;
	}
	return self;
}
	

//twitterの認証を始める
-(void)startTwitterOAuth{
	if(!oAuthTwitterViewController_) {
		oAuthTwitterViewController_ = [[OAuthTwitterViewController alloc]initWithViewFrame:self.view.frame delegate:self];
	}
	[self.view addSubview:oAuthTwitterViewController_.view];
	[oAuthTwitterViewController_ setUpOAuth];
}
//別アカウントでのtwitterの認証を始める
-(void)startTwitterAnotherAccountOAuth{	
	if(!oAuthTwitterViewController_) {
		oAuthTwitterViewController_ = [[OAuthTwitterViewController alloc]initWithViewFrame:self.view.frame delegate:self];
	}
	[self.view addSubview:oAuthTwitterViewController_.view];
	[oAuthTwitterViewController_ setUpOAuthWithAnotherAccountOrNot:YES];
	
	if(yesOrNoCommandView_) {
		[yesOrNoCommandView_ removeFromSuperview];[yesOrNoCommandView_ autorelease];yesOrNoCommandView_ = nil;
	}
}
//すでに認証がされていたら呼ばれる
-(void)twitterOAuthAlreadyAuthenticated{
    if(!liveView_){
        liveView_ = [[LiveView alloc]initWithFrame:CGRectMake(15, 250, 280, 190) withDelegate:self withMaxColumn:4];
        liveView_.overflowMode = WWYLiveViewOverflowMode_noAction;
        [liveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを最初は表示しないように設定。
    }
    [self.view addSubview:liveView_];
	liveView_.actionDelay = 0.0;
	[liveView_ setTextAndGo:NSLocalizedString(@"twitter_account_sudeni_ninshou",@"") actionAtTextFinished:@selector(askAnotheAccountAuth) 
				   userInfo:nil target:self];
}
//別のアカウントで認証するかどうかをユーザに決定させる。
-(void)askAnotheAccountAuth{
	if(!yesOrNoCommandView_){
		yesOrNoCommandView_ = [[WWYCommandView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-70, self.view.frame.size.height/2-50, 140, 1) 
															target:self maxColumnAtOnce:2];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"yes",@"") action:@selector(startTwitterAnotherAccountOAuth) userInfo:nil];
		[yesOrNoCommandView_ addCommand:NSLocalizedString(@"cancel",@"") action:@selector(twitterOAuthCanceled) userInfo:nil];
		[self.view addSubview:yesOrNoCommandView_];
	}
}
//twitter認証が成功したら呼ばれる
-(void)twitterOAuthSuccess{
    if(!liveView_){
        liveView_ = [[LiveView alloc]initWithFrame:CGRectMake(15, 250, 280, 190) withDelegate:self withMaxColumn:4];
        liveView_.overflowMode = WWYLiveViewOverflowMode_noAction;
        [liveView_.moreTextButt setAlpha:0.0];//下の三角ボタンを最初は表示しないように設定。
    }
    [self.view addSubview:liveView_];
	liveView_.actionDelay = 1.5;
	[liveView_ setTextAndGo:NSLocalizedString(@"twitter_account_ninshou_sekou",@"") actionAtTextFinished:@selector(twitterAuthenticationEnded) 
				   userInfo:nil target:delegate_];
}
//twitter認証がキャンセルされたら呼ばれる
-(void)twitterOAuthCanceled{
	[self sendReleaseToAuthTwitterView];
	[delegate_ twitterAuthenticationEnded];
}
//twitter認証が失敗したら（というか「拒否」ボタンを押したとき）呼ばれる。
-(void)twitterOAuthFailed{
	[self sendReleaseToAuthTwitterView];
	[delegate_ twitterAuthenticationEnded];
}
//twitter認証のViewを閉じる。
-(void)sendReleaseToAuthTwitterView{
	//モーダルViewが消えてからreleaseじゃないと、エラーになるらしい。ので5秒後にrelease。
	if(oAuthTwitterViewController_){
		[NSTimer scheduledTimerWithTimeInterval:5.0
										 target:oAuthTwitterViewController_
									   selector:@selector(autorelease)
									   userInfo:nil
										repeats:NO];
		oAuthTwitterViewController_ = nil;
	}
}



@end
