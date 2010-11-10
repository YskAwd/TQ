/*
 *  Define.h
 *  WWY2
 *
 *  Created by awaBook on 10/08/13.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

//実際にtweetするかどうか。(開発中むやみにtweetしないように）
//#define TWEET_ENABLE true
#define TWEET_ENABLE false

//twitterへのポストの最後につける文字列（ハッシュタグを設定）
#define TWITTER_HASH_TAG @"#taskquest"

//タスクの実行日時の何秒前に知らせるか。
#define TASK_PRE_NOTIFICATION_SECONDS 300.0//5分

//タスクの先送り後、再度有効になる秒数
#define TASK_SNOOZE_SPAN_SECONDS 360.0//1時間

//タスクがどれくらい近くになれば検知するかのしきい値。(m)
#define TASK_HIT_AREA_METER 80.0

/* 2010/08/17 メモ
 あとやることは以下
 ・あまりにクラス間の機能分けがぐちゃぐちゃなので、ポリシー決める？ パワポかなんかでクラスの機能図をつくる。
 ・sqliteの代わりにuserDeffaultsで？
 */
