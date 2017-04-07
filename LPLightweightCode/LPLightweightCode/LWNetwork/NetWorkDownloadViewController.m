//
//  NetWorkDownloadViewController.m
//  LPLightweightCode
//
//  Created by LP on 2017/4/7.
//  Copyright © 2017年 zou. All rights reserved.
//

#import "NetWorkDownloadViewController.h"
#import "LWNetWork.h"

@interface NetWorkDownloadViewController ()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation NetWorkDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"down load";
    
    [self createImageView];
    
    [self startDownload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createImageView {
    // Dispose of any resources that can be recreated.
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 200, 200)];
    [self.view addSubview:self.imageView];
}

- (void)startDownload {
    // Dispose of any resources that can be recreated.
    
    __weak typeof(self) weakSelf = self;
    
    [[LWNetWork sharedInstance] download:@"http://mpic.spriteapp.cn/ugc/2016/10/08/57f84cc5366fb.gif" parameters:nil progressHandler:^(NSURLSessionTask *task, CGFloat progress) {

    } completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        if ([responseObject isKindOfClass:[NSURL class]]) {
            weakSelf.imageView.image = [UIImage imageWithContentsOfFile:[(NSURL *)responseObject path]];
        }
    }];
}

@end
