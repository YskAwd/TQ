//
//  TaskBattleManager.h
//  WWY2
//
//  Created by awaBook on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWYHelper_DB.h"
#import "WWYTask.h"
#import "Define.h"

@interface TaskBattleManager : NSObject {
	NSMutableArray *tasks_array_;//DBに登録されているタスクが格納された配列。
//	BOOL isNowAttackingTask_;//現在タスクと戦っているかどうか。戦っているならあらたなタスクは検知しない。

}
//保持しているtasks_array_をDBからの取得した最新のものに。
-(void)updateTasks;
//locationの周辺distance(m)以内にあるTaskをretain済みで返す。
-(WWYTask*)taskAroundLocation:(CLLocation*)location withInMeter:(double)distance;

//@property BOOL isNowAttackingTask;//現在タスクと戦っている途中かどうか
@end
