//
//  DTFQualificationSuccessVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFQualificationSuccessVC.h"

@interface DTFQualificationSuccessVC ()

@end

@implementation DTFQualificationSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"社保待遇资格认证";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)back{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3] animated:YES];
}

/**
 退出按钮点击事件

 @param sender 退出按钮
 */
- (IBAction)exitToRootVC:(UIButton *)sender {


    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3] animated:YES];
}

@end
