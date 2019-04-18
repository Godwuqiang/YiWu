//
//  TreatmentDetailTVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/12/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "TreatmentDetailTVC.h"

@interface TreatmentDetailTVC ()

@end

@implementation TreatmentDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"诊疗目录详情";
    self.tableView.tableFooterView = [[UIView alloc] init];
    HIDE_BACK_TITLE;
    [self initView];    
}

#pragma mark - 初始化界面数据
-(void)initView{
    if (nil==self.bean) {
        self.zlmlmc.text = @"暂无数据";
        self.ybfl.text = @"暂无数据";
        self.bm.text = @"暂无数据";
        self.bz.text = @"暂无数据";
    }else{
        self.zlmlmc.text = nil==self.bean.zlxmmc?@"":self.bean.zlxmmc;
        self.ybfl.text = nil==self.bean.ybfl?@"":self.bean.ybfl;
        self.bm.text = nil==self.bean.sbmlbm?@"":self.bean.sbmlbm;
        if(self.bean.beizhu==nil || [self.bean.beizhu isEqual:[NSNull null]] || [self.bean.beizhu isEqual:@""])
        {
            self.bz.text = @"暂无";
        }else{
            self.bz.text = self.bean.beizhu;
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
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        if ([Util IsStringNil:self.bean.zlxmmc]) {
            return 44.0;
        }else{
            return [self GetLableHeighWithStr:self.bean.zlxmmc];
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
    
    CGSize retSize =  [attributedString boundingRectWithSize:CGSizeMake(self.tableView.width-150, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    return retSize.height+20;
}


@end
