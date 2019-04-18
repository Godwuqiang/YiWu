//
//  InfoDetailTVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/12.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "InfoDetailTVC.h"

@interface InfoDetailTVC ()

@property(nonatomic, assign) BOOL   isShowKh;

@end

@implementation InfoDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的个人信息";
    HIDE_BACK_TITLE;
    [self initView];
}

#pragma mark - 初始化界面数据
-(void)initView{
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    if ([type isEqualToString:@"1"]) {     // 市民卡
        self.Type.text = @"社 会 保 障号";
        self.KhCell.hidden = NO;
        self.isShowKh = YES;
        NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
        self.Kh.text = [Util HeadStr:kh WithNum:0];
    }else{
        self.Type.text = @"身  份  证  号";
        self.KhCell.hidden = YES;
        self.isShowKh = NO;
    }
    
    self.Name.text = [CoreArchive strForKey:LOGIN_NAME];
    NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
    self.Shbzh.text = [Util HeadStr:sbh WithNum:0];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    self.Yhkh.text = [Util HeadStr:bk WithNum:0];
    
    if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {  // 医保移动支付
        self.Ydzf.text = @"已开通";
        self.Ydzf.textColor = [UIColor greenColor];
    }else{
        self.Ydzf.text = @"未开通";
        self.Ydzf.textColor = [UIColor colorWithHex:0xacacac];
    }
    
    if ([[CoreArchive strForKey:LOGIN_BANKZF_STATUS] isEqualToString:@"1"]){  // 银行卡支付
        self.Yhkzf.text = @"已开通";
        self.Yhkzf.textColor = [UIColor greenColor];
    }else{
        self.Yhkzf.text = @"未开通";
        self.Yhkzf.textColor = [UIColor colorWithHex:0xacacac];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(cell == self.KhCell && !self.isShowKh)
        return 0;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
