//
//  CatchTapOnMapView.h
//  WWY2
//
//  Created by awaBook on 10/08/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	MapViewのタップを取得するためのView

#import <UIKit/UIKit.h>


@interface CatchTapOnMapView : UIView {
	id delegate_;
	BOOL isCatchEnable_;
}
- (id)initWithFrame:(CGRect)frame withDelegate:(id)delegate;
@property BOOL isCatchEnable_;

@end
