//
//  DTFQualificationFailVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFQualificationFailVC.h"

@interface DTFQualificationFailVC ()


/** 资格认证失败原因 */
@property (weak, nonatomic) IBOutlet UILabel *failReasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation DTFQualificationFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"社保待遇资格认证";
    self.failReasonLabel.text = self.failedReason;
    self.tipsLabel.text = self.warnTips;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮
}


/**
 返回
 */
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 重新认证按钮点击事件

 @param sender 重新认证按钮
 */
- (IBAction)reQualificationButtonClick:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
}


@end
