//
//  LWNetWork.m
//  SDKTools
//
//  Created by LP on 2017/4/6.
//  Copyright © 2017年 zou. All rights reserved.
//

#import "LWNetWork.h"

typedef void (^LWURLSessionCompletionHandler)(NSURLSessionTask *task, id responseObject, NSError *error);
typedef void (^LWURLSessionProgressHandler)(NSURLSessionTask *task, CGFloat progress);

#pragma mark - LWURLSessionTaskDelegate

@interface LWURLSessionTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURL *downloadLocationUrl;
@property (nonatomic, copy) LWURLSessionCompletionHandler completionHandler;
@property (nonatomic, copy) LWURLSessionProgressHandler progressHandler;
@property (nonatomic, strong) NSSet *jsonTypeSet;
@property (nonatomic, strong) NSSet *imageTypeSet;

@end


@implementation LWURLSessionTaskDelegate

- (instancetype)init
{
    if (self = [super init])
    {
        self.mutableData = [NSMutableData data];
        self.jsonTypeSet = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
        self.imageTypeSet = [NSSet setWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];
    }
    
    return self;
}


- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
   didCompleteWithError:(NSError *)error
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        
        if (error)
        {
            if (weakSelf.completionHandler)
            {
                weakSelf.completionHandler(task, nil, error);
            }
        }
        else
        {
            id data = nil;
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]])
            {
                data = [weakSelf.downloadLocationUrl copy];
            }
            else if ([task isKindOfClass:[NSURLSessionDataTask class]])
            {
                if ([weakSelf.jsonTypeSet containsObject:task.response.MIMEType])
                {
                    data = [NSJSONSerialization JSONObjectWithData:self.mutableData
                                                           options:NSJSONReadingMutableLeaves
                                                             error:nil];
                }
                else if ([weakSelf.imageTypeSet containsObject:task.response.MIMEType])
                {
                    data = [UIImage imageWithData:self.mutableData];
                }
            }
            
            if (weakSelf.completionHandler)
            {
                weakSelf.completionHandler(task, data, error);
            }
        }
    });
}

//  NSURLSessionDataTaskDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
}

//  NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
    self.downloadLocationUrl = location;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        if (weakSelf.progressHandler)
        {
            weakSelf.progressHandler(downloadTask, 1.0);
        }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (!self.progressHandler) return;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        CGFloat progress = 0;
        if (totalBytesWritten > 0 && totalBytesExpectedToWrite > 0)
        {
            progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        }
        weakSelf.progressHandler(downloadTask, progress);
    });
}

@end

#pragma mark - LWNetWork

@interface LWNetWork ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *taskDelegates;

@end


@implementation LWNetWork

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

//  init
- (id)init {
    if (self = [super init]) {
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
        
        self.taskDelegates = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
            completionHandler:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                 URLString:URLString
                                                parameters:parameters];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    //  delegate
    [self addDelegateForTask:task
             progressHandler:nil
           completionHandler:completionHandler];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDownloadTask *)download:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                       progressHandler:(void (^)(NSURLSessionTask *task, CGFloat progress))progressHandler
                     completionHandler:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                 URLString:URLString
                                                parameters:parameters];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    
    //  delegate
    [self addDelegateForTask:task
             progressHandler:progressHandler
           completionHandler:completionHandler];
    
    [task resume];
    
    return task;
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
{
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    
    for (NSString *key in parameters.allKeys) {
        [mutableRequest setValue:parameters[key] forHTTPHeaderField:key];
    }
    
    return mutableRequest;
}

//  cache delegate
- (void)addDelegateForTask:(NSURLSessionTask *)task
           progressHandler:(void (^)(NSURLSessionTask *task, CGFloat progress))progressHandler
         completionHandler:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completionHandler
{
    //  delegate
    LWURLSessionTaskDelegate *delegate = [[LWURLSessionTaskDelegate alloc] init];
    delegate.completionHandler = completionHandler;
    delegate.progressHandler = progressHandler;
    
    //  save
    self.taskDelegates[@(task.taskIdentifier)] = delegate;
}

- (LWURLSessionTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    LWURLSessionTaskDelegate *delegate = nil;
    delegate = self.taskDelegates[@(task.taskIdentifier)];
    
    return delegate;
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    [self.taskDelegates removeObjectForKey:@(task.taskIdentifier)];
}

// - NSURLSessionDelegate
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error
{
    [[self delegateForTask:task] URLSession:session
                                       task:task
                       didCompleteWithError:error];
    
    //  移除
    [self removeDelegateForTask:task];
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [[self delegateForTask:dataTask] URLSession:session
                                       dataTask:dataTask
                                 didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
    [[self delegateForTask:downloadTask] URLSession:session
                                       downloadTask:downloadTask
                          didFinishDownloadingToURL:location];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [[self delegateForTask:downloadTask] URLSession:session
                                       downloadTask:downloadTask
                                       didWriteData:bytesWritten
                                  totalBytesWritten:totalBytesWritten
                          totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

@end
