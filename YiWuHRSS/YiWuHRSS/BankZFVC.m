//
//  BankZFVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BankZFVC.h"
#import "BtnCell.h"
#import "BankKTVC.h"

@interface BankZFVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation BankZFVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"银行卡支付开通";
    // 让title显示居中
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"xx"
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    DMLog(@"lx=%@",self.lx);
    HIDE_BACK_TITLE;
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化界面
-(void)initView{
    self.zftableview.dataSource = self;
    self.zftableview.delegate = self;
    self.zftableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.zftableview.tableFooterView = [[UIView alloc] init];
    [self.zftableview registerNib:[UINib nibWithNibName:@"BtnCell" bundle:nil] forCellReuseIdentifier:@"BtnCell"];
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
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xFDB731]];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 44;
    }else if (indexPath.row==1) {
        return [self GetLableHeigh];
    }else{
        return 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        static NSString  *TitleCellID = @"TitleCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellID];
        if ( nil == cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellID];
            
        }
        cell.textLabel.text = @"银行卡支付功能说明";
        cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
        
        return cell;
    }else if (indexPath.row==1) {
        static NSString  *NetDetailCellID = @"NetDetailCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NetDetailCellID];
        if ( nil == cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NetDetailCellID];
            
        }
        [cell.textLabel setNumberOfLines:0];
        cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        NSString *lb = @"1.开通银行卡支付后，可实现在义乌市医保定点医疗机构普通门诊费用的互联网移动支付，现金支付部分从市民卡的银行账户中扣除。\n 2.开通过程有任何问题，请联系0579-96150。";
        
        NSString *tit = [NSString stringWithFormat:@"%@",lb];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tit];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:6];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lb length])];
        cell.textLabel.attributedText = attributedString;
        return cell;
    }else{
        BtnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BtnCell"];
        if ( nil == cell ){
            cell = [[BtnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BtnCell"];
            
        }
        [cell.agreeBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [cell.agreeBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}


#pragma mark - 获取lable的可变的高度
-(CGFloat)GetLableHeigh{
    
    NSString *lb = @"1.开通银行卡支付后，可实现在义乌市医保定点医疗机构普通门诊费用的互联网移动支付，现金支付部分从市民卡的银行账户中扣除。\n   2.开通过程有任何问题，请联系0579-96150。";
    NSString *tit = [NSString stringWithFormat:@"    %@",lb];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tit];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:15];//调整行间距
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attributedString.length)];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    
    CGSize retSize =  [attributedString boundingRectWithSize:CGSizeMake(self.zftableview.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    return retSize.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 下一步按钮
- (void)nextStep{
    BankKTVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BankKTVC"];
    [VC setValue:@"1" forKey:@"lx"];
    [self.navigationController pushViewController:VC animated:YES];
}

@end
