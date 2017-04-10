//
//  NetWorkGetJsonViewController.m
//  LPLightweightCode
//
//  Created by LP on 2017/4/7.
//  Copyright © 2017年 zou. All rights reserved.
//

#import "NetWorkGetJsonViewController.h"
#import "LWNetWork.h"

@interface NetWorkGetJsonViewController ()
@property (nonatomic, strong) UITextView *textView;

@end

@implementation NetWorkGetJsonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"get json";
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.textView];
    
    __weak typeof(self) weakSelf = self;
    [[LWNetWork sharedInstance] GET:@"http://s.budejie.com/topic/list/jingxuan/1/bs0315-iphone-4.5/0-20.json" parameters:nil completionHandler:^(NSURLSessionTask *task, id responseObject, NSError *error) {
        weakSelf.textView.text = [NSString stringWithFormat:@"%@",responseObject];
    }];
}

@end
