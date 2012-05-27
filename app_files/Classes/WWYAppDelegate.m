//
//  WWYAppDelegate.m
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WWYAppDelegate.h"
#import "MainController.h"
#import "WWYViewController.h"
#import "WWYTask.h"
#import "WWYHelper_DB.h"

/* //スプラッシュ画像作成用
#import "LiveView.h"
#import "LiveViewDelegate.h"
*/


@implementation WWYAppDelegate

@synthesize window;
@synthesize mainController_;
@synthesize viewController_;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
    
    //userdefaultsから値を削除（テスト用）
//   if(IS_TEST) [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"playerStatus"];
//   if(IS_TEST) [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"firstLaunchFootprint_1.0"];
    
    // Override point for customization after application launch.
	//windowを自分で作成
	//window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];//こっちだとStatusBarの分を自動計算しない
    window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    //初回起動ならば
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"firstLaunchFootprint_1.0"]){
        helpViewController_ = [[HelpViewController alloc]initWithViewFrame:window.bounds];
        helpViewController_.delegate = self;
        [window addSubview:helpViewController_.view];
        [helpViewController_ startHowtouse];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"firstLaunchFootprint_1.0"];
    }else{//そうでなければ
        [self initWWYViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    //乱数初期化
    //これはアプリ起動時に一回だけ呼べば良い。秒単位。関数実行の度に呼んでると、同じ秒の中で実行した乱数が同じになってしまう。
    srand((unsigned)time(NULL));
    
    
    //アプリがバックグラウンドでプロセスが生きていないときに、Notificationからアクションボタンをタップしたら呼ばれる
    UILocalNotification *notification;
    notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        int taskID = [[launchOptions objectForKey:@"taskID"]intValue];
        if(taskID) [self startTaskBattleFromNotification:taskID];
    }
    
    return YES;
}
//アプリがフォアグラウンドか、バックグラウンドでプロセスが生きているときにNotificationからアクションボタンをタップしたら呼ばれる
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    int taskID = [[userInfo objectForKey:@"taskID"]intValue];
    if(taskID) [self startTaskBattleFromNotification:taskID];
}
//notificationからもらったtaskIDからタスクバトルを開始する
-(void)startTaskBattleFromNotification:(int)taskID{
    WWYHelper_DB* helper_DB = [[WWYHelper_DB alloc]init];
    WWYTask* task = [helper_DB getTaskFromDB:taskID];
    [viewController_  startTaskBattle:task];
    [helper_DB release];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [viewController_.mapViewController_ updateLastTimeMapRegion];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [viewController_.mapViewController_ updateLastTimeMapRegion];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [viewController_ release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark custom method

-(void)initWWYViewController{
    //    CGRect theFrame = [window frame];
    //    CGRect theBounds = [window bounds];
    //    NSLog(@"AWDTEST0 Frame :%f %f %f %f",theFrame.origin.x,theFrame.origin.y,theFrame.size.width,theFrame.size.height);
    //    NSLog(@"AWDTEST0 Bounds:%f %f %f %f",theBounds.origin.x,theBounds.origin.y,theBounds.size.width,theBounds.size.height);
    
	viewController_ = [[WWYViewController alloc]init];
    //viewController_.view.frame = window.frame;
	viewController_.view.frame = window.bounds;    
    [window addSubview:viewController_.view];
}
-(void)closeHelperView{
    [helpViewController_.view removeFromSuperview];
    [helpViewController_ release];helpViewController_ = nil;
    [self initWWYViewController];
}

@end
