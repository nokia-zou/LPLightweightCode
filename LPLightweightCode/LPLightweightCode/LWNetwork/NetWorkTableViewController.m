//
//  NetWorkTableViewController.m
//  LPLightweightCode
//
//  Created by LP on 2017/4/7.
//  Copyright © 2017年 zou. All rights reserved.
//

#import "NetWorkTableViewController.h"
#import "NetWorkDownloadViewController.h"
#import "NetWorkGetJsonViewController.h"

@interface NetWorkTableViewController ()
@property (nonatomic, strong) NSArray *titles;

@end

@implementation NetWorkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"NetWork";
    
    self.titles = [NSArray arrayWithObjects:@"down load",@"get json", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = self.titles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            NetWorkDownloadViewController *download = [[NetWorkDownloadViewController alloc] init];
            [self.navigationController pushViewController:download animated:YES];
        }
            break;
        case 1:{
            NetWorkGetJsonViewController *get = [[NetWorkGetJsonViewController alloc] init];
            [self.navigationController pushViewController:get animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
