//
//  LWNetWorkDataParser.h
//  LPLightweightCode
//
//  Created by LP on 2017/4/8.
//  Copyright © 2017年 zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - LWNetWorkBaseDataParser

@interface LWNetWorkBaseDataParser : NSObject

@property (nonatomic, strong, readonly) NSSet *MIMETypes;

- (id)parseResultForData:(NSData *)data;

@end


#pragma mark - LWNetWorkJsonParser
@interface LWNetWorkJsonParser : LWNetWorkBaseDataParser

@end


#pragma mark - LWNetWorkImageParser
@interface LWNetWorkImageParser : LWNetWorkBaseDataParser

@end


#pragma mark - LWNetWorkDataParseManager

@interface LWNetWorkDataParseManager : NSObject

+ (void)addDataParser:(LWNetWorkBaseDataParser *)parser;

+ (id)parseData:(NSData *)data forMIMEType:(NSString *)MIMEType;

@end
