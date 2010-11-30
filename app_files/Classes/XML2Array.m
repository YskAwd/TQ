//
//  XML2Array.m
//  WWY2
//
//  Created by AWorkStation on 10/11/23.
//  Copyright 2010 Japan. All rights reserved.
//

#import "XML2Array.h"


@implementation XML2Array

- (void)dealloc {	
	if(_outputArray) [_outputArray release];
    [super dealloc];
}

-(id)initWithData:(NSData*)data{
	if(self = [super init]){
		_xmlParser = [[NSXMLParser alloc]initWithData:data];
		[_xmlParser setDelegate:self];
		_outputArray = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void)parse{
	if(_xmlParser) [_xmlParser parse];
}
	
/*
//NSXMLParserのdelegateメソッド************************************************************************
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	NSLog(elementName);
	
	
	if([elementName isEqualToString:@"word"]){
		word_flg_ = TRUE;
	}else if([elementName isEqualToString:@"lat"]){
		lat_flg_ = TRUE;
	}else if([elementName isEqualToString:@"lng"]){
		lng_flg_ = TRUE;
	}else if([elementName isEqualToString:@"address"]){
		address_flg_ = TRUE;

	}else if([elementName isEqualToString:@"error"]){
		//NSLog(@"ParserError");
		[parser abortParsing], NSLog(@"abort parsing!");
		UIAlertView *parserErrorAlert = [[UIAlertView alloc] initWithTitle:@"Search Result"
																   message:@"Not Found"
																  delegate:self
														 cancelButtonTitle:nil
														 otherButtonTitles:@"OK", nil];
		[parserErrorAlert show];
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	NSLog(string);
	if(word_flg_){
		word_flg_ = FALSE;
		annotation_title_ = string;
		[annotation_title_ retain];
	}else if(lat_flg_){
		lat_flg_ = FALSE;
		lat_ = [string floatValue];
		//lat_ = [[[NSNumber alloc]initWithFloat:[string floatValue]]floatValue];
	}else if(lng_flg_){
		lng_flg_ = FALSE;
		lng_ = [string floatValue];
		//lng_ = [[[NSNumber alloc]initWithFloat:[string floatValue]]floatValue];
	}else if(address_flg_){
		address_flg_ = FALSE;
		annotation_subtitle_ = string;
		[annotation_subtitle_ retain];
		//annotationを生成して、mapViewに反映。
		if(lat_!=0 && fabs(lat_)<90.0 && lng_!=0 && fabs(lng_)<180.0){//latとlngがとりうる値ならば
			//「地図上をタップして、Anotationを追加するモード」なら、検索結果もタップしたときと同じ動作に
			if(mapViewController_.isAddAnotationWithTapMode_){
				CLLocationCoordinate2D coordinate = {lat_, lng_};
				[mapViewController_ addAnotationWithTapCoordinate:coordinate];
				//subtitleには住所を入れる
				mapViewController_.nowAddingAnnotation_.subtitle = annotation_subtitle_;
				
			}else{//それ以外なら　地図上にannotationとして追加。お城。
				[mapViewController_ addAnnotationWithLat:lat_ Lng:lng_ title:annotation_title_ 
												subtitle:annotation_subtitle_ annotationType:WWYAnnotationType_castle selected:YES moved:YES];
				[mapViewController_ manageAnnotationsAmount];
			}
		}else{//アラート表示
			UIAlertView *parserErrorAlert = [[UIAlertView alloc] initWithTitle:@"Search Result"
																	   message:@"Not Found"
																	  delegate:self
															 cancelButtonTitle:nil
															 otherButtonTitles:@"OK", nil];
			[parserErrorAlert show];
		}

	}
}
*/
@end
