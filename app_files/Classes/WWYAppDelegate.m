//
//  WWYAppDelegate.m
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WWYAppDelegate.h"
#import "MainController.h"
#import "WWYViewController.h"

/* //スプラッシュ画像作成用
#import "LiveView.h"
#import "LiveViewDelegate.h"
*/

@implementation WWYAppDelegate

@synthesize window;
@synthesize mainController_;
@synthesize viewController_;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after app launch
	viewController_ = [[WWYViewController alloc]init];
	[window addSubview:viewController_.view];
    [window makeKeyAndVisible];
}

-(void)applicationWillTerminate:(UIApplication *)application{
	[viewController_.mapViewController_ updateLastTimeMapRegion];
}
	
- (void)dealloc {
    [viewController_ release];
    [window release];
    [super dealloc];
}

@end
