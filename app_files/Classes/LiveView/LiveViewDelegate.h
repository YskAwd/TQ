//
//  LiveViewDelegate.h
//  RMQuest2
//
//  Created by awaBook on 09/03/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@protocol LiveViewDelegate
//LiveViewのテキスト描画が終わったときに、delegateに通知するメソッド。描画テキストのIDをつけて通知。
//textIDがない場合は、textID=0で送信される。
- (void) liveViewDrawEndedWithID:(int)textID ;
@end
