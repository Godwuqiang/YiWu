//
//  SelectCardVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/10/31.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "SelectCardVC.h"
#import "RegistBySMCardVC.h"
#import "RegistByHXCardVC.h"
#import "SelectCardCellOne.h"


@interface SelectCardVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation SelectCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请先选择市民卡类型,再进行注册"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xFDB731] range:NSMakeRange(2,7)];
    
    self.name.attributedText = str;
    self.name.font = [UIFont systemFontOfSize:15];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化视图
- (void)initView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableview registerNib:[UINib nibWithNibName:@"SelectCardCellOne" bundle:nil] forCellReuseIdentifier:@"SelectCardCellOne"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        //区别屏幕尺寸
        if ( SCREEN_HEIGHT > 667) //6p
        {
            return 260;
        }
        else if (SCREEN_HEIGHT > 568)//6
        {
            return 200;
        }
        else if (SCREEN_HEIGHT > 480)//5s
        {
            return 160;
        }
        else //3.5寸屏幕
        {
            return 150;
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // 设置间距为0.1时，间距为最小值
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCardCellOne *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCardCellOne"];
    if ( nil == cell ){
        cell = [[SelectCardCellOne alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCardCellOne"];
        
    }
    if (indexPath.section==0) {
        cell.Img.image = [UIImage imageNamed:@"card_sm"];
        cell.tit.text = @"社会保障·市民卡";
    }else{
        cell.Img.image = [UIImage imageNamed:@"card_hx"];
        cell.tit.text = @"和谐卡";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section==0) {
        UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
        RegistBySMCardVC * VC = [UB instantiateViewControllerWithIdentifier:@"RegistBySMCardVC"];
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
        RegistByHXCardVC * VC = [UB instantiateViewControllerWithIdentifier:@"RegistByHXCardVC"];
        [self.navigationController pushViewController:VC animated:YES];
    }
}


@end
