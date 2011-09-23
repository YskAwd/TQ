//
//  WWYStatusView.h
//  WWYRPG
//
//  Created by AWorkStation on 11/01/30.
//  Copyright 2011 Japan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface WWYStatusView : UIView {

    NSMutableArray* _statusArray;//各プレイヤーのステータスを入れる配列
	
	//外枠の描画エリア
	CGRect _wakuframe;
    
    //描画色
    UIColor* _drawColor;
}

@end
