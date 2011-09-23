//
//  NetworkConnectionManager.m
//  WWY2
//
//  Created by AWorkStation on 10/11/23.
//  Copyright 2010 Japan. All rights reserved.
//

#import "NetworkConnectionManager.h"
#import "URLConnectionGetter.h"


@implementation NetworkConnectionManager

- (void)dealloc {	
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	if(_connectionManageDictionary) [_connectionManageDictionary release];
    [super dealloc];
}

-(id)init{
	if (self = [super init]) {
		_connectionManageDictionary = [[NSMutableDictionary alloc]init];
	}
	return self;
}

-(NSString*)requestConnectionWithURL:(NSString*)url fromObj:(id)object callbackMethod:(SEL)selector mode:(NSString*)mode{	
	//一意なkey文字列を生成
	NSString* key_string;
	BOOL keyIsUnique = NO;
	while (!keyIsUnique) {//keyが一意じゃなければ繰り返す
		//現在時からkeyを生成
		NSString* key_str = [[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]stringValue];
		if(![_connectionManageDictionary valueForKey:key_str]){
			keyIsUnique = YES;
			key_string = key_str;
		}
	}
	
	//一定時間接続が帰ってこなかった場合に接続をキャンセルするタイマー	
	NSTimer *connection_timer = [NSTimer scheduledTimerWithTimeInterval:NETWORK_CONNECTION_TIME_LIMIT
																 target:self
															   selector:@selector(networkConnectionDidFaild:)
															   userInfo:key_string
																repeats:NO];
	
	//管理用Dictに格納する。入れ子にして、小要素Dictには対象objectとコールバック関数のセレクタの文字列表現とURLConnectionGetterのインスタンスと、処理モード(NSdataダイレクトやxmlパース等)を格納。
	//使用するURLConnectionGetterを生成
	URLConnectionGetter* urlConnectionGetter = [[[URLConnectionGetter alloc]initWithDelegate:self]autorelease];
	//子要素のDictを生成。
	NSDictionary* object_method_URLConnectionGetter_Dict = [NSDictionary dictionaryWithObjectsAndKeys:
											   object,@"object", NSStringFromSelector(selector),@"callbackMethod_name", urlConnectionGetter, @"connectionGetter", mode,@"mode", connection_timer, @"connection_timer", nil];
	
	//管理用Dictに格納。一意なkey文字列をkeyとして
	[_connectionManageDictionary setValue:object_method_URLConnectionGetter_Dict forKey:key_string];

	//URLRequest実行。
	[urlConnectionGetter requestURL:url];
	
	//一意なkey文字列を返す
	return key_string;
}

//接続をキャンセルする
-(void)cancelConnectionForKey:(NSString*)key{
	NSDictionary* targetDict = nil;
	if(targetDict = [_connectionManageDictionary valueForKey:key]){
		if([[targetDict valueForKey:@"connectionGetter"]respondsToSelector:@selector(cancel)]){
			[[targetDict valueForKey:@"connectionGetter"]cancel];
		}
		//管理用dictの中から、対象となる子要素を削除。（各インスタンスへのreleaseもされる）
		[_connectionManageDictionary removeObjectForKey:key];
	}
}

///一定時間接続が帰ってこなかった場合に接続をキャンセルするタイマーから呼ばれる
-(void)networkConnectionDidFaild:(NSTimer*)timer{
	NSString* key_string = [timer userInfo];
	//NSLog(@"key_string:%@",key_string);
	NSDictionary* targetDict;

	//まだ管理用Dictに格納されていれば
	if ([_connectionManageDictionary valueForKey:key_string]) {
		targetDict = [_connectionManageDictionary valueForKey:key_string];
		//対象オブジェクトに通知
		id targetObject = [targetDict valueForKey:@"object"];
		//コールバック関数を実行
		if([targetObject respondsToSelector:@selector(networkConnectionDidFaild:)]){
			[targetObject performSelector:@selector(networkConnectionDidFaild:)
													withObject:key_string];
		}
		
		//接続をキャンセル
		[self cancelConnectionForKey:key_string];
	}
}

//URLConnectionGetterから呼ばれるメソッド（レスポンスを取得する）**********************************************
- (void)receivedDataFromNetwork:(NSData*)data URLConnectionGetter:(id)uRLConnectionGetter{
	//管理用dictの中の、対象となる子要素を検索
	NSString* targetKey = nil;
	NSDictionary* targetDict = nil;
	
	//for(NSDictionary* dict in _connectionManagerArray){
	for(NSString* key in _connectionManageDictionary){
		if(uRLConnectionGetter == [[_connectionManageDictionary valueForKey:key] valueForKey:@"connectionGetter"]){
			targetKey = key;
			targetDict = [_connectionManageDictionary valueForKey:key];
			break;
		}
	}
	if(targetDict){
		//一定時間接続が帰ってこなかった時用のタイマーをストップ
		NSTimer* timer =[targetDict valueForKey:@"connection_timer"] ;
		[timer invalidate];
		
		//引数として渡すobject
		id argument;
		
		NSString *mode = [targetDict valueForKey:@"mode"];
		//モードによってコールバック関数の引数のobjectを分ける
		if ([mode isEqualToString:@"direct_data"]) {
			argument = data;
		}else if ([mode isEqualToString:@"json"]) {
			//NSDataをNSStringに変換
			NSString* jsonString = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
			//さらにNSDictionaryやNSArrayに変換。(コールバックメソッドにはidとして渡す。コールバックメソッド側でキャストして使う。）
			argument = [jsonString JSONValue];
			//NSLog(@"%@", argument);//NSLogにダンプ
			
		}else if ([mode isEqualToString:@"WWYXML2Array"]) {
			//別クラスを使った、XML->配列の処理
		}
		//コールバック関数を実行
		[[targetDict valueForKey:@"object"] performSelector:NSSelectorFromString([targetDict valueForKey:@"callbackMethod_name"])
												 withObject:argument];
		
		//管理用dictの中から、対象となる子要素を削除。（各インスタンスへのreleaseもされる）
		[_connectionManageDictionary removeObjectForKey:targetKey];
	}
}	


@end
