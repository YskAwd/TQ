    //
//  WebViewController.m
//  WWY2
//
//  Created by AWorkStation on 10/11/27.
//  Copyright 2010 Japan. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

- (void)dealloc {
	NSLog(@"WebViewController-dealloc!");
	if ( webView_.loading ) [webView_ stopLoading];
	webView_.delegate = nil;
	[webView_ release]; 
	[reloadButton_ release]; 
	[stopButton_ release]; 
	[backButton_ release]; 
	[forwardButton_ release];
	[barButtonItemSpacer_ release];
	[navigationItem_ release];
	[toolBar_ release];
	[navigationBar_ release];
	[urlString_ release];
	[super dealloc];
}

-(id)initWithUrlString:(NSString*)urlString{
	if(self = [super init]) {
		urlString_ = urlString;
		[urlString_ retain];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.frame = CGRectMake(0, 20, self.view.frame.size.width, 440);
	
	// UIWebViewの設定
	webView_ = [[UIWebView alloc] init];
	webView_.delegate = self;
	webView_.frame = CGRectMake(0, 40, self.view.frame.size.width, 356);
	webView_.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView_.scalesPageToFit = YES;
	[self.view addSubview:webView_];
	
	// ツールバー、ナビゲーションバーとボタンを追加
	toolBar_ =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 416, self.view.frame.size.width, 44)];
	toolBar_.barStyle = UIBarStyleBlackOpaque;
	navigationBar_ = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
	navigationBar_.barStyle = UIBarStyleBlackOpaque;
	
	reloadButton_ =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                  target:self
                                                  action:@selector(reloadDidPush)];
	stopButton_ =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                  target:self
                                                  action:@selector(stopDidPush)];
	
	stopOrReloadButton_ = stopButton_;
	
	backButton_ =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backDidPush)];
	forwardButton_ =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_forward.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(forwardDidPush)];
	
	navigationItem_ = 
	[[UINavigationItem alloc]initWithTitle:@""];
	
	goodbyeButton_ = 
	[[UIBarButtonItem alloc] initWithTitle:@"Close"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(goodbyeDidPush)];
	
	barButtonItemSpacer_ = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil];
	
	
	[navigationItem_ setLeftBarButtonItem:goodbyeButton_ animated:NO];
	
	[toolBar_ setItems:[NSArray arrayWithObjects:backButton_, forwardButton_,barButtonItemSpacer_, stopButton_, nil]];
	[navigationBar_ setItems:[NSArray arrayWithObject:navigationItem_]];
	
	[self.view addSubview:navigationBar_];
	[self.view addSubview:toolBar_];
	
}

//-(void)loadRequest

- (void)reloadDidPush {
	[webView_ reload]; //< ページの再読み込み
}

- (void)stopDidPush {
	if ( webView_.loading ) {
		[webView_ stopLoading]; //< 読み込み中止
	}
}

- (void)backDidPush {
	if ( webView_.canGoBack ) {
		[webView_ goBack]; //< 前のページに戻る
	} 
}

- (void)forwardDidPush {
	if ( webView_.canGoForward ) {
		[webView_ goForward]; //< 次のページに進む
	} 
}

-(void)goodbyeDidPush{
	//画面を閉じる
	[self dismissModalViewControllerAnimated:YES];
}

- (void)updateControlEnabled {
	// インジケータやボタンの状態を一括で更新する
	[UIApplication sharedApplication].networkActivityIndicatorVisible = webView_.loading;
	//stopButton_.enabled = webView_.loading;
	backButton_.enabled = webView_.canGoBack;
	forwardButton_.enabled = webView_.canGoForward;
	if ( webView_.loading ) {
		[toolBar_ setItems:[NSArray arrayWithObjects:backButton_, forwardButton_, barButtonItemSpacer_, stopButton_, nil]];
	} else {
		[toolBar_ setItems:[NSArray arrayWithObjects:backButton_, forwardButton_, barButtonItemSpacer_, reloadButton_, nil]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	// 画面が表示され終わったらWebページの読み込み
	[super viewDidAppear:animated];
	NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:urlString_]];
	[webView_ loadRequest:request];
	[self updateControlEnabled];
}

- (void)viewWillDisappear:(BOOL)animated {
	// 画面を閉じるときにステータスバーのインジケータを確実にOFFにしておく
	[super viewWillDisappear:animated];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
	[self updateControlEnabled];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	navigationItem_.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self updateControlEnabled];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	[self updateControlEnabled];
}



@end
