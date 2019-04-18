//
//  JieGuoVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/16.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "JieGuoVC.h"
#import "GsLoginVC.h"

@interface JieGuoVC ()

@end

@implementation JieGuoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"市民卡预挂失";
    HIDE_BACK_TITLE;
    
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@""
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    
    [self initView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.jg) {
        [self.navigationItem setHidesBackButton:YES];
    }else{
        [self.navigationItem setHidesBackButton:NO];
    }
}

#pragma mark - 初始化界面
-(void)initView{
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    if (self.jg) {     // 挂失成功界面
        [self setupUISuccess];
    }else{             // 挂失失败界面
        [self setupUIFail];
    }
}

#pragma mark - 挂失成功界面UI
-(void)setupUISuccess{
    self.jgImg.image = [UIImage imageNamed:@"icon_success"];
    self.jgLb.text = @"预挂失成功！";
    self.cgts.hidden = NO;
    
}

#pragma mark - 挂失失败界面UI
-(void)setupUIFail{
    self.jgImg.image = [UIImage imageNamed:@"icon_fail"];
    self.jgLb.text = @"预挂失失败！";
    self.cgts.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 我知道了 按钮点击事件
- (IBAction)KnowBtnClicked:(id)sender {
    if (self.jg) {    // 挂失成功点击我知道了，会去往登录界面
        // 登录界面中的提示弹层 用ModifyCardView显示
        GsLoginVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"GsLoginVC"];
        [self.navigationController pushViewController:VC animated:YES];
    }else{             // 挂失失败点击我知道了，会返回上一界面
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
