//
//  YWRegistAndPaymentVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWRegistAndPaymentVC.h"
#import "YWQueryWIthYearVC.h"
#import "YWPaymentOrderVC.h"

@interface YWRegistAndPaymentVC ()

@end

@implementation YWRegistAndPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.registeView.clipsToBounds = YES;
    self.registeView.layer.borderColor = [UIColor colorWithHex:0xFDB731].CGColor;
    self.registeView.layer.borderWidth = 1.0;
    self.registeView.layer.cornerRadius = 10.0;
    
    self.paymentView.clipsToBounds = YES;
    self.paymentView.layer.borderColor = [UIColor colorWithHex:0xFDB731].CGColor;
    self.paymentView.layer.borderWidth = 1.0;
    self.paymentView.layer.cornerRadius = 10.0;
    
    [self setupUI];
    
}

-(void)setupUI{
    
    if(self.registAndPaymentType == EPRegistAndPaymentSeriousIllness){//大病保险
        
        self.title = @"大病保险";
        self.bgImageView.image = [UIImage imageNamed:@"bg_dabing"];
        
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentTreatment){//城乡居民医疗
        
        self.title = @"城乡居民医疗";
        self.bgImageView.image = [UIImage imageNamed:@"bg_jmyiliao"];
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentPension){//城乡居民养老
        
        self.title = @"城乡居民养老";
        self.bgImageView.image = [UIImage imageNamed:@"bg_jmyanglao"];
        
    }
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}



/**
 参保登记按钮点击事件

 @param sender 参保登记按钮
 */
- (IBAction)registButtonClick:(UIButton *)sender {
    
    DMLog(@"参保登记按钮");
    if(self.registAndPaymentType == EPRegistAndPaymentSeriousIllness){//大病保险
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isSeriousIllness = YES;
        queryWIthYearVC.isOnlinePay = NO;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentTreatment){//城乡居民医疗
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isResidentTreatment = YES;
        queryWIthYearVC.isOnlinePay = NO;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentPension){//城乡居民养老
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isJMYangLao = YES;
        queryWIthYearVC.isOnlinePay = NO;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }
}

/**
 在线缴费按钮点击事件

 @param sender 在线缴费
 */
- (IBAction)paymentButtonClick:(UIButton *)sender {
    
    DMLog(@"参保登记按钮");
    if(self.registAndPaymentType == EPRegistAndPaymentSeriousIllness){//大病保险
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isSeriousIllness = YES;
        queryWIthYearVC.isOnlinePay = YES;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentTreatment){//城乡居民医疗
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isResidentTreatment = YES;
        queryWIthYearVC.isOnlinePay = YES;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }else if (self.registAndPaymentType == EPRegistAndPaymentResidentPension){//城乡居民养老
        
        YWQueryWIthYearVC * queryWIthYearVC = [[YWQueryWIthYearVC alloc]init];
        queryWIthYearVC.isJMYangLao = YES;
        queryWIthYearVC.isOnlinePay = YES;
        [self.navigationController pushViewController:queryWIthYearVC animated:YES];
        
    }
    
    return;
}



@end
