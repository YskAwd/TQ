//
//  TaskBattleManager.m
//  WWY2
//
//  Created by awaBook on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskBattleManager.h"


@implementation TaskBattleManager
//@synthesize isNowAttackingTask = isNowAttackingTask_;

-(id)init{
	if(self = [super init]){
//		isNowAttackingTask_ = NO;
		tasks_array_ =[[NSMutableArray alloc]init];
		[self updateTasks];
	}
	return self;
}

//保持しているtasks_array_をDBからの取得した最新のものに。
-(void)updateTasks{
	[tasks_array_ removeAllObjects];
	WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
	NSArray *tasks_array_fromDB = [helperDB getTasksFromDB_undoneOnly:YES];
	[tasks_array_ addObjectsFromArray:tasks_array_fromDB];
	[helperDB release];
}
//locationの周辺distance(m)以内にあるTaskをretain済みで返す。
-(WWYTask*)taskAroundLocation:(CLLocation*)location withInMeter:(double)distance{
	WWYTask* nearestTask = nil;//明示的にnilを代入しないと、nilと判断されなくなったみたい。宣言だけだとだめ。
//	if(!isNowAttackingTask_){
		if([tasks_array_ count]){
			double distance_threshold = distance;//しきい値。
			for(WWYTask *task in tasks_array_){
				
				//タスクの実行時間何分前かを計算
				NSTimeInterval timeInterval_toMission;
				NSDate *nowDate = [NSDate date];
				if(task.mission_datetime) timeInterval_toMission = [task.mission_datetime timeIntervalSinceDate:nowDate];
				//NSLog(@"task ID:%d title:%@ timeInterval_toMission:%f",task.ID,task.title,timeInterval_toMission);
				//タスクの実行時間が設定されてないか、実行時間5分前以内ならば
				if(!task.mission_datetime || timeInterval_toMission < TASK_PRE_NOTIFICATION_SECONDS){
				
					NSTimeInterval timeInterval_fromSnoozed;
					//先送りした時間が設定されているタスクなら、現在時との差を求める。
					if(task.snoozed_datetime){
						//NSDate *nowDate = [NSDate date];
						timeInterval_fromSnoozed = [nowDate timeIntervalSinceDate:task.snoozed_datetime];
						//一時間以上たってるなら、今後の負荷軽減のためにタスクからsnoozed_datetimeを削除してしまう。
						if(timeInterval_fromSnoozed > TASK_SNOOZE_SPAN_SECONDS){
							task.snoozed_datetime = nil;
							WWYHelper_DB *helperDB = [[[WWYHelper_DB alloc]init]autorelease];
							[helperDB updateTask:task];
						}
					}
					//先送りした時間が設定されていないタスクか、上記で求めた時間差が一時間以上なら、
					//現在地との差を求める。
					if(!task.snoozed_datetime || timeInterval_fromSnoozed > TASK_SNOOZE_SPAN_SECONDS){
						CLLocation *myLocation = [[CLLocation alloc]initWithLatitude:task.coordinate.latitude longitude:task.coordinate.longitude];
						double myDistance;
						if([myLocation respondsToSelector:@selector(distanceFromLocation:)]){
							myDistance = [myLocation distanceFromLocation:location];//このメソッドはOS3.2以降。
						}else if([myLocation respondsToSelector:@selector(getDistanceFrom:)]){
							//上記の代替メソッドを実行。
							myDistance = [myLocation getDistanceFrom:location];////このメソッドはOS3.2未満。
						}
						//一番近いタスクを出力する。
						if(myDistance < distance_threshold){
							nearestTask = task;
							[nearestTask retain];
							distance_threshold = myDistance;
						}
						if(nearestTask && NSLOG_REPORT_ENABLE) NSLog(@"near task ID:%d title:%@ distance:%lf",nearestTask.ID, nearestTask.title, myDistance);
						[myLocation release];
					}
				}
			}
		}
//		if(nearestTask) isNowAttackingTask_ = YES;
//	}
	return nearestTask;//nilなら該当タスクなし。
}
//一定時間タスクが呼ばれないようにする。先送りする。
-(BOOL)snoozeTask:(int)taskID{
//-(BOOL)snoozeTask:(WWYTask*)task{
    WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
    
    //IDからtaskを取得
    WWYTask* task = [helperDB getTaskFromDB:taskID];
    //NSLog(@"task retainCount:%d",[task retainCount]);
    
	//現在時
	NSDate *nowDate = [NSDate date];
	
	//taskに反映
	task.snoozed_datetime = nowDate;
	
	//taskをupdate
	BOOL success = [helperDB updateTask:task];	
    
    [self updateTasks];
    [helperDB release];
    return success;
}
//タスクに現在の終了日時を入れる
-(BOOL)setDoneDatetimeOnTask:(int)taskID{
    WWYHelper_DB *helperDB = [[WWYHelper_DB alloc]init];
    
    //IDからtaskを取得
    WWYTask* task = [helperDB getTaskFromDB:taskID];
    
	//現在時
	NSDate *nowDate = [NSDate date];
	
	//taskに反映
	task.done_datetime = nowDate;
	
	//taskをupdate
	BOOL success = [helperDB updateTask:task];	
    
    [self updateTasks];
    [helperDB release];
    return success;
}


@end
