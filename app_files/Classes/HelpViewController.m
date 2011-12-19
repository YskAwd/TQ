//
//  HelpViewController.m
//  WWY2
//
//  Created by locolocode on 11/12/05.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "WWYAppDelegate.h"

@implementation HelpViewController

@synthesize delegate = delegate_;

- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [commandView_ autorelease];
    [liveView_ autorelease];
    [textArrayDict_ autorelease];
	
    [super dealloc];
}

- (id)initWithViewFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        // Custom initialization
        textArrayDict_ = [[self getTextsArrayDisctionary]retain];
        
        self.view.frame = frame;
        CGRect cViewFrame = CGRectMake(frame.origin.x+frame.size.width*1/10, frame.origin.y+frame.size.height*1.7/10, frame.size.width*8/10, frame.size.height*4/10);
        CGRect lViewFrame = CGRectMake(frame.origin.x+frame.size.width*1/10, frame.origin.y+frame.size.height*3/10, frame.size.width*8/10, frame.size.height*4/10);
        
        commandView_ = [[WWYCommandView alloc]initWithFrame:cViewFrame target:self maxColumnAtOnce:6];
        [commandView_ addCommand:@"たすくくえすとについて" action:@selector(showHelp:) 
                        userInfo:[NSDictionary dictionaryWithObject:@"howtoUse" forKey:@"key"]];
        [commandView_ addCommand:@"たすくのついか" action:@selector(showHelp:) 
                        userInfo:[NSDictionary dictionaryWithObject:@"howtoAddTask" forKey:@"key"]];
        [commandView_ addCommand:@"たすくとのたたかい" action:@selector(showHelp:) 
                        userInfo:[NSDictionary dictionaryWithObject:@"howtoBattle" forKey:@"key"]];
        [commandView_ addCommand:@"ついったーれんけいについて" action:@selector(showHelp:) 
                        userInfo:[NSDictionary dictionaryWithObject:@"aboutTwitter" forKey:@"key"]];
        [commandView_ addCommand:@"さくしゃ　に　ついて" action:@selector(showHelp:) 
                        //userInfo:[NSDictionary dictionaryWithObject:@"aboutAuthor" forKey:@"key"]];
                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"aboutAuthor", @"key", [NSNumber numberWithInt:WWYLiveViewLanguageMode_en], @"language", nil]];
        [commandView_ addCommand:@"とじる" action:@selector(close) userInfo:nil];
        
        liveView_ = [[LiveView alloc]initWithFrame:lViewFrame withDelegate:self withMaxColumn:5];
        liveView_.overflowMode = WWYLiveViewOverflowMode_cursorButton;
        liveView_.actionDelay = 2.0f;
        defaultLiveViewLanguageMode_ = liveView_.language;
        
        self.view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:commandView_];
        //[self.view addSubview:liveView_];
    }
    return self;
}

-(void)re_preset_views{
    [liveView_ removeFromSuperview];
    [commandView_ resetToDefault]; commandView_.touchEnable = YES;
    [self.view addSubview:commandView_];
}

#pragma mark このビューを閉じる
-(void)close{
    if([delegate_ respondsToSelector:@selector(closeHelperView)]){
        [delegate_ closeHelperView];
    }
}

#pragma mark LiveViewへの表示
-(void)showHelp:(id)userInfo{
    //明示的にLiveViewの言語が設定してあれば、それを設定
    if ([userInfo objectForKey:@"language"]) {
        liveView_.language = [[userInfo objectForKey:@"language"]intValue];
    }else{
        liveView_.language = defaultLiveViewLanguageMode_;
    }
    [commandView_ removeFromSuperview];
    [self.view addSubview:liveView_];
    [liveView_ setSeqTextAndGo:[textArrayDict_ objectForKey:[userInfo objectForKey:@"key"]]];
}

#pragma mark - LiveViewDelegateメソッド
- (void)liveViewDrawEndedWithID:(int)textID{
    if([delegate_ isMemberOfClass:[WWYAppDelegate class]]){
        [self close];
    }else{
        [self re_preset_views];
    }
}

#pragma mark アプリスタート時、このアプリについて簡単に紹介
-(void)startHowtouse{
    [commandView_ removeFromSuperview];
    liveView_.actionDelay = 2.0f;
    [self showHelp:[NSDictionary dictionaryWithObject:@"howtoUse" forKey:@"key"]];
}

#pragma mark 説明テキストデータを生成
-(NSDictionary*)getTextsArrayDisctionary{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:
             //[NSString stringWithFormat:@"たすく　くえすと　を　だうんろーど　してくださいまして　ありがとう　ございます。"],
             //[NSString stringWithFormat:@"まず　はじめに　この　あぷりの　つかいかたを　せつめいします。"], 
             @"たすく　くえすと　へ　ようこそ。",
             @"あなた　は　きょうから　ゆうしゃに　なりました。",
             @"ゆうしゃとして　ひびの　たすくを　なしとげて　ください！",
             @"「コマンド」ぼたん　から　ついったーとうろく　を　おこなうと　たすくを　なしとげるごとに　けいけんちがたまります。",
             @"そして　たすく　の　けっか　が　ついーと　されます。",
             @"レベルが　あがると　しょうごうが　もらえます。", 
             @"さあ　ぼうけんへ　しゅっぱつ　しましょう！", 
             nil],
            @"howtoUse",
            
            [NSArray arrayWithObjects:
             @"たすく　を　ついかするには、「コマンド」ぼたん　から 「たすく　ついか」をえらびます。",
             @"まず　たすくを　おこなう　ばしょ　を　ちずで　えらびます。",
             @"そのあと　たすく　の　なまえや、たたかう　あいて　などを　にゅうりょくします。",
             @"いますぐ　たすくを　ついかして　たたかいたい　ばあいは、「たたかうなう！」ぼたんを　つかってください。",
             
             nil],
            @"howtoAddTask",
            
            [NSArray arrayWithObjects:
             @"たすく　に　とうろくした　じかん　に　たすく　に　とうろくした　ばしょに　いくと、たたかい　が　はじまります。",
             @"もし　たすくを　さきのばし　したいばあいは　にげる ことも　できます。",
             nil],
            @"howtoBattle",
            
            [NSArray arrayWithObjects:
             @"ついったーの　せっていを　おこなうと　たすくを　なしとげるごとに　けいけんちがたまります。",                      
             @"なお、たすくのなまえ、たたかうあいて、たすくと　たたかった　じかんは　たすく　しゅうりょうじに　ついったーに　とうこうされます。",
             @"ついったーの　こうしきせってい　で　ついーとに　いちじょうほうを ふか　することを　きょか　する　せっていを　していれば、たすくをおこなった　いちじょうも　とうこうされますので　ちゅういが　ひつようです。",
             nil],
            @"aboutTwitter",
            
            [NSArray arrayWithObjects:
             @"Concept & Direction : \n\n       Hironori Nakahara\n\n       (nD inc.)",                      
             @"Development : \n\n       Yusuke Awazu\n\n       (locolo code)",
             @"Graphic : \n\n       Takateru Chujo",
             nil],
            @"aboutAuthor",
            nil];
}


@end
