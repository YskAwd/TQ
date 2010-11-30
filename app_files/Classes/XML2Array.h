//
//  XML2Array.h
//  WWY2
//
//  Created by AWorkStation on 10/11/23.
//  Copyright 2010 Japan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XML2Array : NSObject <NSXMLParserDelegate>{
	NSXMLParser* _xmlParser;
	NSMutableArray* _outputArray;
}

@end
