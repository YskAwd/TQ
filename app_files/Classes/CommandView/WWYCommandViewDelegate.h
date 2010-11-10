//
//  WWYCommandViewDelegate.h
//  RMQuest2
//
//  Created by awaBook on 09/02/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
@protocol WWYCommandViewDelegate
//コマンドがタップされたとき、以下のメソッドがdelegateに対して実行され、delagateオブジェクトに以下を実装することでコマンドの各要素が取得できる。
//columnNoは、CommandViewの中の何番目のCommandColumnViewかを通知。
//columnIdは、各CommandColumnViewに設定された識別するためのID。
//cmdViewIdは、CommandViewに設定された識別するためのID。
- (void) commandPushedWithCommandString:(NSString*)commandString withColumnNo:(int)columnNo withColumnID:(int)columnId withCommandViewId:(int)commandViewId ;

@end
