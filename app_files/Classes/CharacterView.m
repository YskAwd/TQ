//
//  CharacterView.m
//  WWY
//
//  Created by awaBook on 09/07/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterView.h"

@implementation CharacterView
	
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
		   withCharaType:(int)type {
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		imageSeqStep = 0;
		currentDirection = 2;
		
		//キャラ画像の名前をDBより取得。typeをキーに。
		FMRMQDBSelect* DBSelect= [[FMRMQDBSelect alloc]init];
		NSMutableString*  queryString = [NSMutableString stringWithString:@"SELECT image FROM character WHERE charaType="];
		NSNumber* typeNum = [NSNumber numberWithInt:type];
		//NSNumber* typeNum = [NSNumber numberWithInt:1];
		[queryString appendString:[typeNum stringValue]];
		FMResultSet* rs = [DBSelect selectFromDBWithQueryString:queryString];
		
		//rsから取り出す。
		NSString* imageStr;
		while ([rs next]) {
			imageStr =[rs stringForColumn:@"image"];
			//NSLog(imageStr);
		}
		NSArray* charaImegeGyouArray=[imageStr componentsSeparatedByString:@","];
		NSMutableArray* charaImegeArray=[[NSMutableArray alloc]init];
		for(int i=0;i<[charaImegeGyouArray count];i++){
			[charaImegeArray addObject:[[charaImegeGyouArray objectAtIndex:i]componentsSeparatedByString:@":"]];
		}
		//できた配列charaImegeArrayには、charaImegeArray[前左後右][各フレーム画像]という形で格納される
		//NSLog([[charaImegeArray objectAtIndex:0]objectAtIndex:0]);
		//以下アニメーション用の配列。initWithObjectsで生成し、autoreleaseをしない。そうしないとこの関数終わったら消えてしまうので。
		//とりあえず下記のように生成してるが、もしフレーム数が4つ以外のキャラが出てきたら、NSMutableArrayにして、for文で[charaImegeArray count]だけ要素を加えていく形で生成する。
		//また、キャラの絵が何らかのイベントで変わる場合も、NSMutableArrayにすれば画像を入れ替えることができる。さらに必要ならプロパティとしてこの配列をもてば外部から画像を入れ替えることもできるかな。
		characterImageArrayFront=[[NSMutableArray alloc]initWithObjects:
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:0]objectAtIndex:0]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:0]objectAtIndex:1]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:0]objectAtIndex:2]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:0]objectAtIndex:3]],nil];
		characterImageArrayLeft=[[NSMutableArray alloc]initWithObjects:
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:1]objectAtIndex:0]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:1]objectAtIndex:1]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:1]objectAtIndex:2]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:1]objectAtIndex:3]],nil];
		characterImageArrayBack=[[NSMutableArray alloc]initWithObjects:
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:2]objectAtIndex:0]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:2]objectAtIndex:1]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:2]objectAtIndex:2]],
								 [UIImage imageNamed:[[charaImegeArray objectAtIndex:2]objectAtIndex:3]],nil];
		characterImageArrayRight=[[NSMutableArray alloc]initWithObjects:
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:3]objectAtIndex:0]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:3]objectAtIndex:1]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:3]objectAtIndex:2]],
								  [UIImage imageNamed:[[charaImegeArray objectAtIndex:3]objectAtIndex:3]],nil];
		
		characterImageArrays=[[NSMutableArray alloc]initWithObjects:characterImageArrayBack,characterImageArrayRight,
							  characterImageArrayFront,characterImageArrayLeft,nil];
		
		
		[charaImegeArray release];
		[DBSelect release];

		[self animationStart];
		
		self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];

    }
		return self;
}

//charaTypeをキーにキャラを再設定するメソッド
-(void)reassignCharacter:(int)charaType{
	//キャラ画像の名前をDBより取得。typeをキーに。
	FMRMQDBSelect* DBSelect= [[FMRMQDBSelect alloc]init];
	NSMutableString*  queryString = [NSMutableString stringWithFormat:@"SELECT image FROM character WHERE charaType=%d",charaType];
	FMResultSet* rs = [DBSelect selectFromDBWithQueryString:queryString];
	
	//rsから取り出す。
	NSString* imageStr;
	while ([rs next]) {
		imageStr =[rs stringForColumn:@"image"];
	}
	NSArray* charaImegeGyouArray=[imageStr componentsSeparatedByString:@","];
	NSMutableArray* charaImegeArray=[[NSMutableArray alloc]init];
	for(int i=0;i<[charaImegeGyouArray count];i++){
		[charaImegeArray addObject:[[charaImegeGyouArray objectAtIndex:i]componentsSeparatedByString:@":"]];
	}
		
	//charaImegeArrayには、charaImegeArray[前左後右][各フレーム画像]という形で格納されている
	for(int i=0; i<4; i++){
		[characterImageArrayFront replaceObjectAtIndex:i withObject:[UIImage imageNamed:[[charaImegeArray objectAtIndex:0]objectAtIndex:i]]];
	}
	for(int i=0; i<4; i++){
		[characterImageArrayLeft replaceObjectAtIndex:i withObject:[UIImage imageNamed:[[charaImegeArray objectAtIndex:1]objectAtIndex:i]]];
	}
	for(int i=0; i<4; i++){
		[characterImageArrayBack replaceObjectAtIndex:i withObject:[UIImage imageNamed:[[charaImegeArray objectAtIndex:2]objectAtIndex:i]]];
	}
	for(int i=0; i<4; i++){
		[characterImageArrayRight replaceObjectAtIndex:i withObject:[UIImage imageNamed:[[charaImegeArray objectAtIndex:3]objectAtIndex:i]]];
	}
	[charaImegeArray release];
	[DBSelect release];
}


-(void)animationStart{
	//timer
	if(!baseTimer) {
		baseTimer = [NSTimer scheduledTimerWithTimeInterval:(10.0f)/30.0f	//(3.0f)/30.0f
													 target:self//これで自動的にretainCountが1増えている。
												   selector:@selector(baseTimerLoop:)
												   userInfo:nil
													repeats:YES];
	}
}
-(void)animationStop{
	if(baseTimer) [baseTimer invalidate]; baseTimer=nil;
}

-(void) baseTimerLoop:(NSTimer*)timer{
	self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];
	if(imageSeqStep == 3){
		imageSeqStep = 0;
	}else{
		imageSeqStep ++;
	}
}
//turnする処理をbaseTimerの中で実行するだけだと、、タイマーの間隔が遅いのでターンするのが遅く見える。
//なので以下のメソッドの中でも直接実行。
-(void) turnUp
{
	currentDirection = 0;
	self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];
}
-(void) turnRight {
	currentDirection = 1;
	self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];
}
-(void) turnDown {
	currentDirection = 2;
	self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];
}
-(void) turnLeft {
	currentDirection = 3;
	self.image = [[characterImageArrays objectAtIndex:currentDirection]objectAtIndex:imageSeqStep];
}


//現在の位置(currentPos)を設定するメソッド

- (void)drawRect:(CGRect)rect {
    // Drawing code
}
//このクラスのインスタンスを破棄する際には、"close"メソッドを明示的に呼ぶこと。
//内部タイマーによるretainCountなどをうまいことやってくれる。
//closeメソッド呼ばないと、retainCountが0にならず、解放できない。
-(void)close{
	//timerを止めて無効に。//自動的にselfのretainCountが1減る。
	if(baseTimer) [baseTimer invalidate]; baseTimer=nil;
}

- (void)dealloc {
	NSLog(@"CharacterView----------dealloc!!!");
	//if(baseTimer) [baseTimer invalidate]; baseTimer=nil;//ここでTimer止めるとダメ。invalidateすることによってselfのrCountが1減るからクラッシュする。そのため"close"メソッドを用意。
    //このクラスのインスタンスを破棄する際には、"close"メソッドを明示的に呼ぶこと。
	//内部タイマーによるretainCountなどをうまいことやってくれる。
	//closeメソッド呼ばないと、retainCountが0にならず、解放できない。
	
	//characterImageArrays等を解放。
	[characterImageArrays removeAllObjects];
	[characterImageArrays release];
	[characterImageArrayFront removeAllObjects];
	[characterImageArrayFront release];
	[characterImageArrayRight removeAllObjects];
	[characterImageArrayRight release];
	[characterImageArrayLeft removeAllObjects];
	[characterImageArrayLeft release];
	[characterImageArrayBack removeAllObjects];
	[characterImageArrayBack release];
	
	[super dealloc];
}

@end
