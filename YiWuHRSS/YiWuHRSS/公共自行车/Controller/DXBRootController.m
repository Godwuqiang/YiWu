//
//  DXBRootController.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBRootController.h"
#import "DXBLocationGaoDeManager.h"

@interface DXBRootController ()

@end

@implementation DXBRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)currentCity {
    
    DXBLocationGaoDeManager *current = [DXBLocationGaoDeManager sharedManager];
    return current.current_city;
}

- (NSString *)show_longitude {
    
    return @"120.063697";
}

- (NSString *)show_latitude {
    
    return @"29.293017";
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
