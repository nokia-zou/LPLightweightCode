//
//  LWNetWork.h
//  SDKTools
//
//  Created by LP on 2017/4/6.
//  Copyright © 2017年 zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWNetWork : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
            completionHandler:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completionHandler;

- (NSURLSessionDownloadTask *)download:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                       progressHandler:(void (^)(NSURLSessionTask *task, CGFloat progress))progressHandler
                     completionHandler:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completionHandler;

@end
