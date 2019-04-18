//
//  SettingVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "SettingVC.h"
#import "ChangLoginPsdVC.h"
#import "ChangAddressVC.h"
#import "YWChangeMobileNumVC.h"


@interface SettingVC ()

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    HIDE_BACK_TITLE;
    [self setupLoginPsdView];
    [self setupPhoneView];
    [self setupAddressView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xF8AB26]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 为修改登录密码VIEW添加手势
- (void)setupLoginPsdView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LoginPsdViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.LoginPswView addGestureRecognizer:singleTapRecognizer];
}

#pragma mark - 跳转至修改登录密码界面
- (void)LoginPsdViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    DMLog(@"修改登录密码");
    ChangLoginPsdVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangLoginPsdVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 为修改注册手机号添加手势
- (void)setupPhoneView{
    UITapGestureRecognizer* tap;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PhoneViewHandleSingleTapFrom)];
    tap.numberOfTapsRequired = 1;
    [self.PhoneView addGestureRecognizer:tap];
}

- (void)PhoneViewHandleSingleTapFrom {
    
    YWChangeMobileNumVC *vc = [[YWChangeMobileNumVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 为家庭地址VIEW添加手势
- (void)setupAddressView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AddressViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.AddressView addGestureRecognizer:singleTapRecognizer];
}

#pragma mark - 跳转至修改家庭地址界面
- (void)AddressViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    DMLog(@"修改家庭住址");
    
    //无卡权限拦截
    if(![YWManager sharedManager].isHasCard){
        
        [self showNoCardTips];
        return ;
    }
    
    
    ChangAddressVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangAddressVC"];
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark - 提示无卡
-(void)showNoCardTips{
    
    [EPTipsView ep_showAlertView:@"未查询到您名下的卡片信息，不能进行相关操作！" buttonText:@"我知道了" toView:self.tabBarController.view  buttonBlock:^{
        
    }];
}


@end
