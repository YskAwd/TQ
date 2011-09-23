//
//  WWYHelper_DB.h
//  WWY
//
//  Created by awaBook on 09/12/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class WWYMapViewController;
@class CharacterView;
@class WWYTask;
#import "WWYTask.h"
#import "Define.h"

//カスタムSQLite操作用
#import "FMRMQDBSelect.h"
#import "FMRMQDBUpdate.h"
#import "FMResultSet.h"

@interface WWYHelper_DB : NSObject {
	//SELECTするときブリッジになってくれるオブジェクト
	FMRMQDBSelect* DBSelect_;
	//UPDATEするときブリッジになってくれるオブジェクト
	FMRMQDBUpdate* updateDB_;
}
//DBからannotationの情報を取得して、mapViewにいれる(WWYMapViewControllerのメソッドを使用)
-(void)getAnnotationsFromDB:(WWYMapViewController*)mapViewController_;
//mapViewのannotationをDBのannotationsテーブルに反映
-(void)updateAnnotations:(NSArray*)annotations;
//パーティーの並び順をDBに格納。引数はNSNumberを格納した配列。
-(void)updatePartyOrder:(NSArray*)partyOrderArray;
//パーティーの並び順をDBから取得して、NSNumberを格納した配列として返す。
-(NSArray*)selectPartyOrder;
//パーティーの並び順をDBから取得してキャラに適用する。
-(void)reassignCharacterFromDB:(WWYMapViewController*)mapViewController_;
//taskをDBに登録する。登録成功すればtaskID、登録に失敗したら0を返す。
-(int)insertTask:(WWYTask*)task;
//ひとつのtaskをdbにアップデートする。
-(BOOL)updateTask:(WWYTask*)task;
//全てのtaskを取得してその配列を返す(配列はretainされていない)。
-(NSArray*)getTasksFromDB_undoneOnly:(BOOL)undoneOnly;
@end
