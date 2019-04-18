//
//  MedicalDetailTVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/12/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "MedicalDetailTVC.h"

@interface MedicalDetailTVC ()

@end

@implementation MedicalDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"药品目录详情";
    self.tableView.tableFooterView = [[UIView alloc] init];
    HIDE_BACK_TITLE;
    [self initView];
}

#pragma mark - 初始化界面数据
-(void)initView{
    if (nil==self.bean) {
        self.ypmc.text = @"暂无数据";
        self.jx.text = @"暂无数据";
        self.ybfl.text = @"暂无数据";
        self.xysm.text = @"暂无数据";
        self.bm.text = @"暂无数据";
        self.gg.text = @"暂无数据";
        self.cj.text = @"暂无数据";
    }else{
        self.ypmc.text = nil==self.bean.ypmc?@"暂无":self.bean.ypmc;
        self.jx.text = nil==self.bean.jx?@"暂无":self.bean.jx;
        self.ybfl.text = nil==self.bean.yibaofenlei?@"暂无":self.bean.yibaofenlei;
        self.xysm.text = nil==self.bean.xysm?@"暂无":self.bean.xysm;
        self.bm.text = nil==self.bean.sbmlbm?@"暂无":self.bean.sbmlbm;
        self.gg.text = nil==self.bean.gg?@"暂无":self.bean.gg;
        if(self.bean.cj==nil||[self.bean.cj isEqual:[NSNull null]]||[self.bean.cj isEqual:@""])
        {
            self.cj.text = @"暂无";
        }else
        {
            self.cj.text = self.bean.cj;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return [self GetLableHeighWithStr:self.bean.ypmc];
    }else if (indexPath.row==3){
        if ([Util IsStringNil:self.bean.xysm]) {
            return 44.0;
        }else{
            return [self GetLableHeighWithStr:self.bean.xysm];
        }
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - 获取lable的可变的高度
-(CGFloat)GetLableHeighWithStr:(NSString*)str{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    
    CGSize retSize =  [attributedString boundingRectWithSize:CGSizeMake(self.tableView.width-145, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    

    return retSize.height+20;
}


@end
