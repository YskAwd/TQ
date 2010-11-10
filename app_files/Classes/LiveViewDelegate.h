//
//  LiveViewDelegate.h
//  RMQuest2
//
//  Created by awaBook on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@protocol LiveViewDelegate

@required

//LiveViewのテキスト描画が終わったときに、delegateに通知するメソッド。描画テキストのIDをつけて通知。
//textIDがない場合は、textID=0で送信される。
- (void) liveViewDrawEndedWithID:(int)textID ;

@optional
//LiveViewのテキストがあふれたとき、delegateに通知するメソッド。
//LiveViewのoverflowModeがWWYLiveViewOverflowMode_delegateActionの場合のみ実行される。
- (void) liveViewTextDidOverflow ;

@end
