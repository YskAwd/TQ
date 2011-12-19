//
//  WWYHelper_DB.m
//  WWY
//
//  Created by awaBook on 09/12/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWYHelper_DB.h"
#import "WWYMapViewController.h"
#import "CharacterView.h"
#import "WWYTask.h"

//このクラス、なぜかinit時にautoreleaseするとフリーズする可能性が高い。
//できるだけ遅いタイミングでautoreleaseするように。
//また、releaseだと画面描画との関係か、フリーズしたこともあるので、autoreleaseの方がよいかも。

@implementation WWYHelper_DB
+(id)helperDB{
	return [[[WWYHelper_DB alloc]init]autorelease];
}
-(id)init{
	if([super init]){
		//inititalization
		DBSelect_= [[FMRMQDBSelect alloc]init];
		updateDB_ = [[FMRMQDBUpdate alloc]init];
	}
	return self;
}

//DBからannotationの情報を取得して、mapViewにいれる(WWYMapViewControllerのメソッドを使用)
-(void)getAnnotationsFromDB:(WWYMapViewController*)mapViewController_{
	//DBから取得
	NSMutableString*  queryString = [NSString stringWithString:@"SELECT title,subtitle,latitude,longitude FROM annotations"];
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
	
	//rsから取り出して、mapViewに入れる
	while ([rs next]) {
		//NSLog(@"[rs stringForColumn:@"latitude"] rCount: %d",[[rs stringForColumn:@"latitude"]retainCount]);//->
		[mapViewController_ addAnnotationWithLat:[[rs stringForColumn:@"latitude"]floatValue] Lng:[[rs stringForColumn:@"longitude"]floatValue]
										   title:[rs stringForColumn:@"title"] subtitle:[rs stringForColumn:@"subtitle"] annotationType:WWYAnnotationType_castle selected:NO moved:NO];
	}
	//NSLog(@"DBSelect_ rCount1: %d",[DBSelect_ retainCount]);//->1
}

//mapViewのannotationをDBのannotationsテーブルに反映
-(void)updateAnnotations:(NSArray*)annotations{
	//DBのannotationsテーブルのレコードを全削除
	//sql文を生成
	NSMutableString* queryStr = @"DELETE FROM annotations;";
	//DBへ反映
	[updateDB_ upDateDBWithQueryString:queryStr];
	NSLog(@"queryStr: %@",queryStr);
	queryStr = nil;
	
	//1件ずつレコードを登録（ほんとはコロンで繋げたINSERT文で全件一括で入れたかったけど、FMDatabaseが対応してないのか最初の1件しか入らなかったので断念）
	id <MKAnnotation> annotation;
	int i =0;
	for(annotation in annotations){
		queryStr = [NSString stringWithFormat:@"INSERT INTO annotations ('id','title','subtitle','latitude','longitude') VALUES ('%d', '%@', '%@', '%f', '%f'); "
							,i,[annotation title],[annotation subtitle],annotation.coordinate.latitude,annotation.coordinate.longitude];
		[updateDB_ upDateDBWithQueryString:queryStr];
				//NSLog(@"queryStr rCount: %d",[queryStr retainCount]);//->1
		queryStr = nil;
		i++;
	}
}

//パーティーの並び順をDBに格納。引数はNSNumberを格納した配列。
-(void)updatePartyOrder:(NSArray*)partyOrderArray{
	//DBのpartyテーブルのレコードを全削除
	//sql文を生成
	NSMutableString* queryStr = @"DELETE FROM party;";
	//DBへ反映
	[updateDB_ upDateDBWithQueryString:queryStr];
	NSLog(@"queryStr: %@",queryStr);
	queryStr = nil;
	
	//1件ずつレコードを登録（ほんとはコロンで繋げたINSERT文で全件一括で入れたかったけど、FMDatabaseが対応してないのか最初の1件しか入らなかったので断念）
	for(int i=0; i<[partyOrderArray count]; i++){
		queryStr = [NSString stringWithFormat:@"INSERT INTO party ('rank','charaType') VALUES ('%d', '%d'); "
					,i,[[partyOrderArray objectAtIndex:i]intValue]];
		[updateDB_ upDateDBWithQueryString:queryStr];
		NSLog(queryStr);//->1
		queryStr = nil;
	}
	 
}

//パーティーの並び順をDBから取得して、NSNumberを格納した配列として返す。
-(NSArray*)selectPartyOrder{
	//DBから取得
	NSMutableString*  queryString = [NSString stringWithString:@"SELECT rank,charaType FROM party ORDER BY rank;"];
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
	
	NSMutableArray* partyOrderArray = [[NSMutableArray alloc]initWithCapacity:0];
	while ([rs next]) {
		[partyOrderArray addObject:[NSNumber numberWithInt:[rs intForColumn:@"charaType"]]];
	}
	return partyOrderArray;//partyOrderArrayのcountはDBにいくつレコード入ってるかに左右されることに注意。4つとは限らない。
}
	

//パーティーの並び順をDBから取得してキャラに適用する。
-(void)reassignCharacterFromDB:(WWYMapViewController*)mapViewController_{
	//DBから取得
	NSMutableString*  queryString = [NSString stringWithString:@"SELECT rank,charaType FROM party ORDER BY rank;"];
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];

	//rsから取り出して、キャラを変更する
	int i=0;
	while ([rs next]) {
		if(i < [mapViewController_.characterAnnotationArray_ count]){//ループ回数がキャラクター数を超えないように
			//NSLog(@"charaType: %@",[rs stringForColumn:@"charaType"]);
			CharacterView* cView = [mapViewController_.mapView_ viewForAnnotation:[mapViewController_.characterAnnotationArray_ objectAtIndex:i]];
			[cView reassignCharacter:[rs intForColumn:@"charaType"]];
			i++;
		}
	}
}
#pragma mark -
#pragma mark タスク関係
//DBから未達成のタスクを取得して、mapViewにAnnotationとしていれる(WWYMapViewControllerのメソッドを使用)
-(void)getTasksFromDBOnMapViewController:(WWYMapViewController*)mapViewController{
	//DBから取得し、mapViewにAnnotationとして入れる
	NSArray* taskArray = [self getUndoneTasksFromDB];
    [self addAnotationTaskOnMapview:mapViewController taskArray:taskArray];
}
//DBから達成済みのタスクを取得して、mapViewにAnnotationとしていれる(WWYMapViewControllerのメソッドを使用)
-(void)getDoneTasksFromDBOnMapViewController:(WWYMapViewController*)mapViewController{
	//DBから取得
	NSArray* taskArray = [self getDoneTasksFromDB];
    
    //mapViewにpolylineのoverlayをのせる
    CLLocationCoordinate2D coors[[taskArray count]];
    for(int i=0; i<[taskArray count]; i++){
        WWYTask* task = [taskArray objectAtIndex:i];
        coors[i] = task.coordinate;
        //mapViewでのAnnotationタイトル、サブタイトル。mapView上でのみの表記。
        
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setLocale:[NSLocale systemLocale]];
        //[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        //NSString *doneDateStr = [dateFormatter stringFromDate:task.done_datetime];
        //task.title = [NSString stringWithFormat:@"%@\n%@",task.title,doneDateStr];
        //[dateFormatter release];
        //タスク名は、なければモンスター名、それもなければデフォルト名。
//        if(!task.title || [task.title isEqualToString:@""]) task.title = NSLocalizedString(@"task_name_example_at_battle",nil);
        
        //タスク完了日をsubtitleに表示するため、タスク実施予定日に入れる。
        task.mission_datetime = task.done_datetime;
    }
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coors
                                                     count:[taskArray count]];
    [mapViewController.mapView_ addOverlay:line];
    //mapViewControllerのプロパティとしてpolylineを保持する。あとで消すときに使うので。
    mapViewController.taskHistoryPolyline = line;
    
    //mapViewにAnnotationとして入れる
    [self addAnotationTaskOnMapview:mapViewController taskArray:taskArray];
}
//MapviewControllerの中にtaskArrayのタスクをannotationとして入れる（このクラス内部で使う）
-(void)addAnotationTaskOnMapview:(WWYMapViewController*)mapViewController_ taskArray:(NSArray*)taskArray{
    //mapViewにAnnotationとして入れる
	for (WWYTask *task in taskArray){
        //anotationタイトルは、タスクのタイトルがない場合は敵の名前、それもない場合はデフォルト値。
        NSString* annotationTitle = task.title;
        if(!annotationTitle || [annotationTitle isEqualToString:@""]) annotationTitle = task.enemy;
        if(!annotationTitle || [annotationTitle isEqualToString:@""]) annotationTitle = NSLocalizedString(@"task_name_example_at_battle",@"");
        
        //anotationのサブタイトルは、mission_datetimeとdescriptionを合わせたもの。
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        NSString *missionDateStr = [dateFormatter stringFromDate:task.mission_datetime];
        if(!missionDateStr) missionDateStr = @"";
        NSString* annotationSubTitle = [NSString stringWithFormat:@"%@ %@",missionDateStr,task.description];
        if(annotationSubTitle.length > 20) {
            annotationSubTitle = [annotationSubTitle substringToIndex:17];
            annotationSubTitle = [NSString stringWithFormat:@"%@%@",annotationSubTitle,@"..."];
        }else if([annotationSubTitle isEqualToString:@" "]){
            annotationSubTitle = nil;
        }
        
        //タスクがまだ実行されていない物なのか、勝ったのか負けたのかによって、annotationTypeを分ける。
        WWYAnnotationType annotationType;
        if(task.done_datetime){
            if (task.win) annotationType = WWYAnnotationType_taskBattleArea_won;
            else annotationType = WWYAnnotationType_taskBattleArea_lost;
        }else{
            annotationType = WWYAnnotationType_taskBattleArea;
        }
        
        //anotationをMapに配置
		[mapViewController_ addAnnotationWithLat:task.coordinate.latitude Lng:task.coordinate.longitude
										   title:annotationTitle subtitle:annotationSubTitle 
								  annotationType:annotationType 
                                        userInfo:[NSNumber numberWithInt:task.ID]
                                        selected:NO
										   moved:NO];
	}
}
//mapView内のタスクのAnnotationを、DBから最新の未達成のタスクに入れ替える。(WWYMapViewControllerのメソッドを使用)
-(void)updateTaskAnnotationsFromDB:(WWYMapViewController*)mapViewController{
    //タスクのAnnotationを削除
    [self removeTaskAnnotationFromMapViewController:mapViewController];
    //dbから取得したタスクをマップに入れる
	[self getTasksFromDBOnMapViewController:mapViewController];
}
//mapViewControllerからタスクのAnnotationを削除
-(void)removeTaskAnnotationFromMapViewController:(WWYMapViewController*)mapViewController{
    //タスクのAnnotationを削除
	NSMutableArray* currentAnnotationArray = [NSMutableArray arrayWithArray:mapViewController.mapView_.annotations];
	for (id<MKAnnotation> annotation in currentAnnotationArray){
		if([annotation isKindOfClass:[WWYAnnotation class]] && [annotation respondsToSelector:@selector(annotationType)]){
			//タスクのAnnotationなら
			if([annotation annotationType] == WWYAnnotationType_taskBattleArea
               || [annotation annotationType] == WWYAnnotationType_taskBattleArea_won
               || [annotation annotationType] == WWYAnnotationType_taskBattleArea_lost) {
				[mapViewController.mapView_ removeAnnotation:annotation];
			}
		}		
	}
}

//taskをDBに登録する。登録成功すればtaskID、登録に失敗したら0を返す。
-(int)insertTask:(WWYTask*)task{
	BOOL success = NO;
	int lastInsertTaskId = 0;
    
	//mission_datetimeをStringに
	NSString *mission_datetime = nil;
	if (task.mission_datetime) {//snoozed_datetimeがあるなら
		mission_datetime = [self stringFromDate:task.mission_datetime];
	}
	//snoozed_datetimeをStringに
	NSString *snoozed_datetime = nil;
	if (task.snoozed_datetime) {//snoozed_datetimeがあるなら
		snoozed_datetime = [self stringFromDate:task.snoozed_datetime];
	}
    //done_datetimeをStringに
	NSString *done_datetime = nil;
	if (task.done_datetime) {//done_datetimeがあるなら
		done_datetime = [self stringFromDate:task.done_datetime];
	}
	
	//sql文を生成
	NSMutableString* queryStr = [NSString stringWithFormat:@"INSERT INTO tasks ('title','description','enemy','enemy_image_id','latitude','longitude','mission_datetime','snoozed_datetime','done_datetime') VALUES ('%@', '%@', '%@', '%d', '%f', '%f', '%@', '%@', '%@'); "
                                 ,task.title,task.description,task.enemy,task.enemyImageId,task.coordinate.latitude,task.coordinate.longitude,mission_datetime,snoozed_datetime,done_datetime];
	NSLog(@"queryStr: %@",queryStr);
	
    //DBへ反映
	lastInsertTaskId = [updateDB_ insertDBWithQueryString:queryStr];
	queryStr = nil;
    
	return lastInsertTaskId;
}
//全てのtaskを取得してその配列を返す(autorelease済み)。
-(NSArray*)getTasksFromDB{
    NSMutableString*  queryString = [NSString stringWithFormat:@"SELECT id,title,description,enemy,enemy_image_id,latitude,longitude,mission_datetime,snoozed_datetime,done_datetime,win FROM tasks ORDER BY id;"];
    
    //DBから取得
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
    
	return [self getTasksArrayFromResultSet:rs];
}
//まだ終了していないタスクのみ取得してその配列を返す（autorelease済み）
-(NSArray*)getUndoneTasksFromDB{
    //done_datetimeで終了しているタスクか判断する
    NSMutableString* queryString = [NSString stringWithFormat:@"SELECT id,title,description,enemy,enemy_image_id,latitude,longitude,mission_datetime,snoozed_datetime,done_datetime,win FROM tasks WHERE done_datetime IS NULL OR done_datetime LIKE '' OR done_datetime LIKE '(NULL)' ORDER BY id;"];
    
    //DBから取得
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
    
	return [self getTasksArrayFromResultSet:rs];
}
//終了したタスクのみ取得してその配列を返す。終了日時順で。（autorelease済み）
-(NSArray*)getDoneTasksFromDB{
    //done_datetimeで終了しているタスクか判断する
    NSMutableString* queryString = [NSString stringWithFormat:@"SELECT id,title,description,enemy,enemy_image_id,latitude,longitude,mission_datetime,snoozed_datetime,done_datetime,win FROM tasks WHERE done_datetime IS NOT NULL AND done_datetime NOT LIKE '' AND done_datetime NOT LIKE '(NULL)' ORDER BY done_datetime;"];
    
    //DBから取得
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
    
	return [self getTasksArrayFromResultSet:rs];
}
//NSResultSetからTaskの配列にする。
-(NSArray*)getTasksArrayFromResultSet:(FMResultSet*)rs{
    NSMutableArray* tasks = [[[NSMutableArray alloc]init]autorelease];
	while ([rs next]) {
		CLLocationCoordinate2D coordinate;
		coordinate.latitude = [rs doubleForColumn:@"latitude"];
		coordinate.longitude= [rs doubleForColumn:@"longitude"];
		WWYTask *task = [[WWYTask alloc]initWithID:[rs intForColumn:@"id"] title:[rs stringForColumn:@"title"] description:[rs stringForColumn:@"description"] enemy:[rs stringForColumn:@"enemy"] enemyImageId:[rs intForColumn:@"enemy_image_id"] coordinate:coordinate];
		task.mission_datetime = [self dateFromString:[rs stringForColumn:@"mission_datetime"]];
		task.snoozed_datetime = [self dateFromString:[rs stringForColumn:@"snoozed_datetime"]];
        task.done_datetime = [self dateFromString:[rs stringForColumn:@"done_datetime"]];
        task.win = [rs boolForColumn:@"win"];
		[tasks addObject:task];
		[task release];
	}
	return tasks;
}
//ひとつのtaskをdbから取得する。(autorelease済み)
-(WWYTask*)getTaskFromDB:(int)taskID{
	//DBから取得
	NSMutableString*  queryString = [NSString stringWithFormat:@"SELECT id,title,description,enemy,enemy_image_id,latitude,longitude,mission_datetime,snoozed_datetime,done_datetime,win FROM tasks WHERE id = '%d';",
									 taskID];
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
	
	WWYTask *task;
	while ([rs next]) {
		CLLocationCoordinate2D coordinate;
		coordinate.latitude = [rs doubleForColumn:@"latitude"];
		coordinate.longitude= [rs doubleForColumn:@"longitude"];
		task = [[WWYTask alloc]initWithID:[rs intForColumn:@"id"] title:[rs stringForColumn:@"title"] description:[rs stringForColumn:@"description"] enemy:[rs stringForColumn:@"enemy"] enemyImageId:[rs intForColumn:@"enemy_image_id"] coordinate:coordinate];
		task.mission_datetime = [self dateFromString:[rs stringForColumn:@"mission_datetime"]];
		task.snoozed_datetime = [self dateFromString:[rs stringForColumn:@"snoozed_datetime"]];
        task.done_datetime = [self dateFromString:[rs stringForColumn:@"done_datetime"]];
        task.win = [rs boolForColumn:@"win"];
	}
    [task autorelease];
	return task;
}
//ひとつのtaskをdbにアップデートする。
-(BOOL)updateTask:(WWYTask*)task{
	[task retain];	
	BOOL success = NO;

    //下記の日時関連、NULLの場合、DBには'(NULL)'という文字列が入ってしまっているよう。問題あるなら修正。
	//mission_datetimeをStringに
	NSString *mission_datetime = nil;
	if (task.mission_datetime) {//snoozed_datetimeがあるなら
		mission_datetime = [self stringFromDate:task.mission_datetime];
	}
	//snoozed_datetimeをStringに
	NSString *snoozed_datetime = nil;
	if (task.snoozed_datetime) {//snoozed_datetimeがあるなら
		snoozed_datetime = [self stringFromDate:task.snoozed_datetime];
	}
    //done_datetimeをStringに
	NSString *done_datetime = nil;
	if (task.done_datetime) {//done_datetimeがあるなら
		done_datetime = [self stringFromDate:task.done_datetime];
	}
    
	//sql文を生成
	NSMutableString* queryStr = [NSString stringWithFormat:@"UPDATE tasks SET 'title'='%@', 'description'='%@', 'enemy'='%@', 'enemy_image_id'='%d', 'latitude'='%f', 'longitude'='%f', 'mission_datetime'='%@', 'snoozed_datetime'='%@', 'done_datetime'='%@','win'='%d' WHERE id = %d ;"
								 ,task.title,task.description,task.enemy,task.enemyImageId,task.coordinate.latitude,task.coordinate.longitude,mission_datetime,snoozed_datetime,done_datetime,task.win,task.ID];
	
	//DBへ反映
	success = [updateDB_ upDateDBWithQueryString:queryStr];
	NSLog(@"queryStr: %@",queryStr);
	queryStr = nil;
	
	[task release];
	return success;
}
//ひとつのタスクを消去する。
-(BOOL)deleteTask:(int)taskID{
	BOOL success = NO;
	
	//sql文を生成
	NSMutableString* queryStr = [NSString stringWithFormat:@"DELETE FROM tasks WHERE id = %d ;"
								 ,taskID];
	
	//DBへ反映
	success = [updateDB_ upDateDBWithQueryString:queryStr];
	//NSLog(@"queryStr: %@",queryStr);
	queryStr = nil;

	return success;
}

//NSDateをNSStringに決まったフォーマットで変換する。
-(NSString*)stringFromDate:(NSDate*)date{
	//フォーマッター
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	//「en_US」ロケールでString化
	NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFormatter setLocale:locale];
	NSString *outputTxt = [dateFormatter stringFromDate:date];
	return outputTxt;
}
//NSStringをNSDateに決まったフォーマットで変換する。
-(NSDate*)dateFromString:(NSString*)string{
	//フォーマッター
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	//「en_US」ロケールのStringからDate化
	NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]autorelease];
	[dateFormatter setLocale:locale];
	NSDate *outputDate = [dateFormatter dateFromString:string];
	return outputDate;
}
//指定したモンスターIdのUIImageを返す
-(UIImage*)getEnemyImageViewWithId:(int)enemyImageId{
    return [UIImage imageNamed:[NSString stringWithFormat:@"mon%d.gif",enemyImageId]];
    //return [UIImage imageNamed:@"monster.gif"];
}
#pragma mark -
#pragma mark Twitter関係
//twitterのusernameをDBに保存
-(BOOL)updateTwitterUsername:(NSString*)username{
	[username retain];
	BOOL success = NO;
	//sql文を生成
	NSMutableString* queryStr = [NSString stringWithFormat:@"UPDATE player SET 'name'='%@', 'twitter_name'='%@' WHERE id = 1 ;"
								 ,username,username];
	
	//DBへ反映
	success = [updateDB_ upDateDBWithQueryString:queryStr];
	//NSLog(@"queryStr: %@",queryStr);
	
	[username release];
	return success;
}
-(void)dealloc{
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
	
	//インスタンスをリリース
	//NSLog(@"DBSelect_ rCount2: %d",[DBSelect_ retainCount]);//->1
	[DBSelect_ release];
	[updateDB_ release];
	
	[super dealloc];
}
//twitterのusernameをDBから取得して返す。(返り値はretain済み)
-(NSString*)getTwitterUsername{
	NSString *twitter_name = nil;
	//DBから取得
	NSMutableString*  queryString = @"SELECT twitter_name FROM player WHERE id = 1;";
	FMResultSet* rs = [DBSelect_ selectFromDBWithQueryString:queryString];
	while ([rs next]) {
			twitter_name = [rs stringForColumn:@"twitter_name"];
	}
	[twitter_name retain];
	return twitter_name;
}

@end
