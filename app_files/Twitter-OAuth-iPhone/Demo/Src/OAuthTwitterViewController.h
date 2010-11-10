//
//  OAuthTwitterViewController.h
//  OAuthTwitterDemo
//
//  Created by Ben Gottlieb on 7/24/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "Define.h"

@class SA_OAuthTwitterEngine;


@interface OAuthTwitterViewController : UIViewController <SA_OAuthTwitterControllerDelegate> {
	SA_OAuthTwitterEngine				*_engine;
	id _delegate;
	UIViewController *_controller;
}
@end

