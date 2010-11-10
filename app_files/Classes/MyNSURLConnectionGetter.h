//
//  MyNSURLConnectionGetter.h
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//NSURLConnectionを使って、非同期でweb等のネットワークからデータを取ってくるクラス。
//今のところ同時に1接続しかできないように設計してある。複数接続したい場合は、このクラスのインスタンス自体を複数作ることになる。

#import <Foundation/Foundation.h>
@class WWYViewController;

@interface MyNSURLConnectionGetter : NSObject {
	WWYViewController* delegate_;
	NSURLConnection* urlConnection_;
	NSMutableData* data_;
}

- (id)initWithDelegate:(WWYViewController*)deleg;
-(void)cancel;
-(void)requestURL:(NSString*)urlString;

@end
