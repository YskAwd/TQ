//
//  TwitterAuthViewController.h
//  WWY2
//
//  Created by awaBook on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthTwitterViewController.h"
#import "LiveView.h"
#import "WWYCommandView.h"
#import "WWYHelper_DB.h"
#import "Define.h"
@class WWYViewController;


@interface TwitterAuthViewController : UIViewController <LiveViewDelegate>{
	
	OAuthTwitterViewController *oAuthTwitterViewController_;
	WWYViewController *delegate_;
	LiveView *liveView_;
	WWYCommandView *yesOrNoCommandView_;
	
}

@end
