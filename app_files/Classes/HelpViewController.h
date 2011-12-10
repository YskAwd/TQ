//
//  HelpViewController.h
//  WWY2
//
//  Created by locolocode on 11/12/05.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "LiveView.h"
#import "WWYCommandView.h"

@interface HelpViewController : UIViewController <LiveViewDelegate>{
    LiveView *liveView_;
    WWYCommandView *commandView_;
    NSDictionary* textArrayDict_;
    id delegate_;
}
@property (assign) id delegate;

- (id)initWithViewFrame:(CGRect)frame;
@end
