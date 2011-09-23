/*
 *  Define.h
 *  WWY2
 *
 *  Created by awaBook on 10/08/13.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#pragma mark -
#pragma mark テストモード

//テストモードかどうか（falseの場合は、以下全てのAT_TESTがついた設定値が無視される）
#define IS_TEST true
//#define IS_TEST false

//テストモード時にtweetするかどうか。(開発中むやみにtweetしないように）
#define TWEET_ENABLE_AT_TEST true
//#define TWEET_ENABLE_AT_TEST true false

//locationが取得できない環境での開発用に、ウソのlocationをプッシュするか
#define PUSH_DAMMY_LOCATION_AT_TEST true

//テスト用に、UserDefaultに保存されてる値をAWDefaultValueの値で上書きするかどうか。
#define OVERRIDE_AW_DEFAULT_VALUE_AT_TEST true
//#define OVERRIDE_AW_DEFAULT_VALUE_AT_TEST false
/*------------------------------------------------------------*/
#pragma mark -
#pragma mark タスク関連

//タスクの実行日時の何秒前に知らせるか。
#define TASK_PRE_NOTIFICATION_SECONDS 300.0//5分

//タスクの先送り後、再度有効になる秒数
#define TASK_SNOOZE_SPAN_SECONDS 600.0//10分

//タスクがどれくらい近くになれば検知するかのしきい値。(m)
//locationの精度にあわせた方がいいかも
#define TASK_HIT_AREA_METER 200.0

//定期的に近くにタスクがないかをチェックする間隔の秒数。なお、新しいlocationが取得されるごとにチェックはされる。
#define TASK_CHECK_INTERVAL 5.0//5秒

//タスク入力欄の文字数制限
#define TASK_NAME_TEXT_LIMIT_NUM 20 //20文字まで（半角全角の判別はしていない）
#define TASK_DESCRIPTION_TEXT_LIMIT_NUM 200 //200文字まで（半角全角の判別はしていない）
/*------------------------------------------------------------*/
#pragma mark -
#pragma mark twitter and bitly

//twitterへのポストの最後につける文字列（ハッシュタグを設定）
#define TWITTER_HASH_TAG @"taskquest.in #taskquest_dev"

//twitterのOAuthに使うアプリケーションkey
#define kOAuthConsumerKey				@"7bdtTEnyVoBbKfHfp1VAA"
#define kOAuthConsumerSecret			@"9fIvJyfCFxcIvenIdSxdwXSxUVg9NcxeCMPlFokXPI"

//bitlyのAPIKey
//locolocode
/*#define BITLY_USER_NAME @"locolocode"
 #define BITLY_API_KEY @"R_aad0024ae7ea786e10364b15bb992cb6"*/
/*------------------------------------------------------------*/
#pragma mark -
#pragma mark location
/*
//locationを取得する時間（長いほど正確）
#define GPS_MEASURING_TIME 10.0 //単位:秒
//locationの精度
#define GPS_DESIRED_ACCURACY kCLLocationAccuracyBest
//あまりに距離が離れたlocationをはじくためのしきい値
#define GPS_UNADOPTABLE_ACCURACY 2000.0 //単位:m
*/
/*------------------------------------------------------------*/
#pragma mark -
#pragma mark basic

//dealloc時にNSLog出力
#define DEALLOC_REPORT_ENABLE true
//#define DEALLOC_REPORT_ENABLE false

//レポート系のNSLog出力
//#define NSLOG_REPORT_ENABLE true
#define NSLOG_REPORT_ENABLE false

//NetworkConnectionManagerで、結果が帰ってこない場合に接続をキャンセルする秒数
#define NETWORK_CONNECTION_TIME_LIMIT 30.0f//30秒

/*------------------------------------------------------------*/


/* 2010/08/17 メモ
 あとやることは以下
 ・あまりにクラス間の機能分けがぐちゃぐちゃなので、ポリシー決める？ パワポかなんかでクラスの機能図をつくる。
 ・sqliteの代わりにuserDeffaultsで？
 */
