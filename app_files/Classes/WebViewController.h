//
//  WebViewController.h
//  WWY2
//
//  Created by AWorkStation on 10/11/27.
//  Copyright 2010 Japan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
@private
	UIWebView* webView_;
	UIToolbar* toolBar_;
	UINavigationBar* navigationBar_;
	UIBarButtonItem* reloadButton_;
	UIBarButtonItem* stopButton_;
	UIBarButtonItem* stopOrReloadButton_;
	UIBarButtonItem* backButton_;
	UIBarButtonItem* forwardButton_;
	UIBarButtonItem* goodbyeButton_;
	UIBarButtonItem *barButtonItemSpacer_;
	UINavigationItem* navigationItem_;
	NSString* urlString_;
}

@end
