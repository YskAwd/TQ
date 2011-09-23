//
//  WWYStatusView.m
//  WWYRPG
//
//  Created by AWorkStation on 11/01/30.
//  Copyright 2011 Japan. All rights reserved.
//

#import "WWYStatusView.h"
#import "StatusManager.h"
#import "AWBuiltInValuesManager.h"

@implementation WWYStatusView


- (void)dealloc {
	if(DEALLOC_REPORT_ENABLE) NSLog(@"[DEALLOC]:%@", NSStringFromClass([self class]) );
    [_drawColor autorelease];
    [_statusArray autorelease];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
        self.opaque = NO;
        self.backgroundColor = [UIColor blackColor];
        _drawColor = [[UIColor whiteColor]retain];
        
        //ステータスを入れる配列
        _statusArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        [self refreshStatus];
        
		

		//枠の描画エリア
		//_wakuframe = self.frame;
	}
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	//枠を書く
	CGContextRef context = UIGraphicsGetCurrentContext();
	//CGContextSetGrayStrokeColor(context, 1, 1);
    CGContextSetStrokeColorWithColor(context, _drawColor.CGColor);
	CGContextSetLineWidth(context, 3);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextStrokeRect(context, CGRectMake(3, 3, _wakuframe.size.width-6, _wakuframe.size.height-6));
	
    
	//文字を描画
    
    //各文字列の描画エリア
    float outerMarginX = 10.0; float outerMarginY = 10.0;//このViewの外枠とのマージン
    float innerMarginX = 3.0; float innerMarginY = 3.0;//互いのテキストの縦横のマージン
    int lineCount = 6;//縦の行数
    CGRect textAreaFrame = CGRectMake(self.frame.origin.x+outerMarginX , self.frame.origin.y+outerMarginY, self.frame.size.width-outerMarginX*2, self.frame.size.height-outerMarginY*2);
    
    //色、フォント
    CGColorRef textColor = [_drawColor CGColor];
    CGContextSetFillColorWithColor(context, textColor);
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    
    for (int i=0; i<[_statusArray count]; i++) {
        //frameを配列に
        NSMutableArray* frameArray = [NSMutableArray arrayWithCapacity:0];
        for (int j=0; j<lineCount; j++) {
            CGRect stringDrawRect = CGRectMake(textAreaFrame.origin.x+textAreaFrame.size.width*i/4+innerMarginX,
                                               textAreaFrame.origin.y+textAreaFrame.size.height*j/lineCount+innerMarginY, textAreaFrame.size.width-innerMarginX*2,
                                               textAreaFrame.size.height*j/lineCount-innerMarginY*2);
            [frameArray addObject:[NSValue valueWithCGRect:stringDrawRect]];
        }
        
        NSDictionary* status = [_statusArray objectAtIndex:i];
        //文字描画
        for (NSString* key in [status allKeys]) {
            if([key isEqualToString:@"name"]){
                [[[NSMutableString alloc]initWithFormat:@"%@ : %@",NSLocalizedString(@"name",@""),[status objectForKey:@"name"]] drawInRect:[[frameArray objectAtIndex:0]CGRectValue] withFont:font];
            }
            else if([key isEqualToString:@"title"]){
                [[[NSMutableString alloc]initWithFormat:@"%@ : %@",NSLocalizedString(@"shougou",@""),[status objectForKey:@"title"]] drawInRect:[[frameArray objectAtIndex:1]CGRectValue] withFont:font];
            }
            else if([key isEqualToString:@"lv"]){
                [[[NSMutableString alloc]initWithFormat:@"%@ : %d",NSLocalizedString(@"lv",@""),[[status objectForKey:@"lv"]intValue]] drawInRect:[[frameArray objectAtIndex:2]CGRectValue] withFont:font];
            }
            else if([key isEqualToString:@"ex"]){
                [[[NSMutableString alloc]initWithFormat:@"%@ : %d",NSLocalizedString(@"ex",@""),[[status objectForKey:@"ex"]intValue]] drawInRect:[[frameArray objectAtIndex:3]CGRectValue] withFont:font];
            }
            else if([key isEqualToString:@"next_ex"]){
                [[[NSMutableString alloc]initWithFormat:@"%@ : %d",NSLocalizedString(@"ex_to_next_level",@""),[[status objectForKey:@"next_ex"]intValue]] drawInRect:[[frameArray objectAtIndex:4]CGRectValue] withFont:font];
            }
            
        }
    }
}


//パーティの人数によって枠の大きさを変える
-(void)setNumberOfParty:(int)number{
	//_wakuframe = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width*number/4, self.frame.size.height);
	_wakuframe = self.frame;//一定の枠にした。
}


-(void)refreshStatus{
    [_statusArray removeAllObjects];
    
    //パーティのステータスを取得
    StatusManager *statusManager = [StatusManager statusManager];
    int lv = [statusManager getIntegerParameterOfPlayerStatus:@"lv"];
    int ex = [statusManager getIntegerParameterOfPlayerStatus:@"ex"];
    int next_ex = [statusManager getRequireExAtNextLevel];
    NSString *name = [statusManager getName];
    NSString *title = [statusManager getTitle];
    
    
    //ステータスを入れる
    //for (NSDictionary* status in partyStatusArray){
    NSMutableDictionary* statusDict = [NSMutableDictionary dictionaryWithCapacity:0];
    if (lv) [statusDict setObject:[NSNumber numberWithInt:lv] forKey:@"lv"];
    if (ex) [statusDict setObject:[NSNumber numberWithInt:ex] forKey:@"ex"];
    if (next_ex) [statusDict setObject:[NSNumber numberWithInt:next_ex] forKey:@"next_ex"];
    if (name) [statusDict setObject:name forKey:@"name"];
    if (title) [statusDict setObject:title forKey:@"title"];

    [_statusArray addObject:statusDict];
    //}
    
    [self setNumberOfParty:[_statusArray count]];
    
    [self setNeedsDisplay];
}
//描画色を変える
-(void)changeColor:(UIColor*)color{
    [_drawColor autorelease];
    _drawColor = [color retain];
    
    [self setNeedsDisplay];
}

@end
