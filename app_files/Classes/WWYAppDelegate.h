//
//  WWYAppDelegate.h
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainController;
@class WWYViewController;
#import "HelpViewController.h"

@interface WWYAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MainController *mainController_;
    WWYViewController *viewController_;
    HelpViewController* helpViewController_; 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) MainController *mainController_;
@property (nonatomic, readonly) WWYViewController *viewController_;

@end

