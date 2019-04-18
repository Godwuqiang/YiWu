//
//  DTFAuthCannotFailVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/10/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFAuthCannotFailVC.h"

@interface DTFAuthCannotFailVC ()

@end

@implementation DTFAuthCannotFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"实人认证";
}


/**
 退出按钮点击事件

 @param sender 退出按钮
 */
- (IBAction)exitButtonClick:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
