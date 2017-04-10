//
//  LWNetWorkDataParser.m
//  LPLightweightCode
//
//  Created by LP on 2017/4/8.
//  Copyright © 2017年 zou. All rights reserved.
//

#import "LWNetWorkDataParser.h"


#pragma mark - LWNetWorkBaseDataParser

@implementation LWNetWorkBaseDataParser

- (id)parseResultForData:(NSData *)data
{
    return data;
}

@end


#pragma mark - LWNetWorkJsonParser

@implementation LWNetWorkJsonParser

- (NSSet *)MIMETypes
{
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
}

- (id)parseResultForData:(NSData *)data
{
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableLeaves
                                             error:nil];;
}

@end

#pragma mark - LWNetWorkImageParser

@implementation LWNetWorkImageParser

- (NSSet *)MIMETypes
{
    return [NSSet setWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];
}

- (id)parseResultForData:(NSData *)data
{
    return [UIImage imageWithData:data];
}

@end


#pragma mark - LWNetWorkImageParser

@interface LWNetWorkDataParseManager ()
@property (nonatomic, strong) NSMutableArray *dataParsers;

@end


@implementation LWNetWorkDataParseManager : NSObject

+ (instancetype)sharedInstance {
    static LWNetWorkDataParseManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

//  init
- (id)init
{
    if (self = [super init])
    {
        self.dataParsers = [NSMutableArray arrayWithObjects:[[LWNetWorkJsonParser alloc] init]
                            ,[[LWNetWorkImageParser alloc] init],
                            nil];
    }
    
    return self;
}

+ (void)addDataParser:(LWNetWorkBaseDataParser *)parser
{
    if (!parser || ![parser isKindOfClass:[LWNetWorkBaseDataParser class]]) return;
    [[LWNetWorkDataParseManager sharedInstance].dataParsers addObject:parser];
}

+ (id)parseData:(NSData *)data forMIMEType:(NSString *)MIMEType
{
    for (LWNetWorkBaseDataParser *parser in [LWNetWorkDataParseManager sharedInstance].dataParsers)
    {
        if (parser.MIMETypes && [parser.MIMETypes containsObject:MIMEType])
        {
            return [parser parseResultForData:data];
        }
    }
    
    return data;
}

@end

