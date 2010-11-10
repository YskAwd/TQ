//
//  DebugViewController.h
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WWYViewController;

@interface DebugViewController : UIViewController {
	IBOutlet WWYViewController* parentViewController;
	IBOutlet UITextView* textViewForDebug;
}
-(IBAction)startMoveUpOnDebug;
-(IBAction)startMoveRightOnDebug;
-(IBAction)startMoveDownOnDebug;
-(IBAction)startMoveLeftOnDebug;
-(IBAction)stopMoveOnDebug;

@property (assign) WWYViewController* parentViewController;//いくらIBOutletつけてても、このようにプロパティ化しなければ、外部クラスからアクセスできない。
@property (assign) UITextView* textViewForDebug;

@end
