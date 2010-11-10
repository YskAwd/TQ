//
//  MyNSURLConnectionGetter.m
//  WWY
//
//  Created by awaBook on 09/08/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyNSURLConnectionGetter.h"
#import "WWYViewController.h"

@implementation MyNSURLConnectionGetter


- (id)initWithDelegate:(WWYViewController*)deleg {
	if([super init]) {
		delegate_ = deleg;
	}
	return self;
}

//外部からこのメソッドを呼ぶと、実際にURLにアクセスし、レスポンスを得る処理が始まる。
-(void)requestURL:(NSString*)urlString{
	//NSString* string = [[NSString alloc]initWithString:urlString];
	if(urlConnection_){
		[urlConnection_ release], urlConnection_ = nil;
	}
	urlConnection_ = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
												  delegate:self];
}
	
-(void)cancel{
	if(urlConnection_) {
		//urlConnection_をキャンセル
		[urlConnection_ cancel];
		//urlConnection_を解放
		[urlConnection_ release];
		urlConnection_ = nil;
	}
	//data_も解放
	if(data_) {
		[data_ release]; data_ = nil;
	}
}

//***********************************************************************************************************
//NSURLConnectionのdelegateメソッド(プロトコルが定義されてる訳ではないが、delegメソッドが定義されている)************************
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	// ダウンロードしたデータを保存しておくためのdata_を初期化
	if(data_){
		//NSLog(@"data_ exsist!");
		[data_ release]; data_ = nil;
	}
//	data_ = [[NSMutableData data] retain];
	data_ = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//ダウンロードされたデータを追加
	//NSLog(@"data RCOUNT1: %d",[data retainCount]);
	[data_ appendData:data];
	//NSLog(@"data RCOUNT2: %d",[data retainCount]);
	//[data autorelease];//これアクティブにすると、シミュレータはOKだが実機だとダメ。アクティブにしないと軽いメモリリーク起きるみたい。
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	//ダウンロード処理が完了
	//data_を使った処理を実行(delegate_にdataを送る)
	[delegate_ recieveDataFromNetwork:data_];
	
	//処理が終わったらdata_を解放
	[data_ release]; data_ = nil;//このnil大事。
	//urlConnection_も解放
	[urlConnection_ release]; urlConnection_ = nil;//このnil大事。
}
- (void)dealloc {
	NSLog(@"MyNSURLConnectionGetter----dealloc!!!");
	[self cancel];
    [super dealloc];
}
@end
