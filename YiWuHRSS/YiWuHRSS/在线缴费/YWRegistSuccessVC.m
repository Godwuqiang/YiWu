//
//  YWRegistSuccessVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWRegistSuccessVC.h"
#import "YWPaymentOrderVC.h"
#import "YWQueryWIthYearVC.h"

@interface YWRegistSuccessVC ()

@end

@implementation YWRegistSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.negativeButton.clipsToBounds = YES;
    self.negativeButton.layer.borderWidth = 1.0;
    self.negativeButton.layer.borderColor = [UIColor colorWithHex:0xFDB731].CGColor;
    self.negativeButton.layer.cornerRadius = 5.0;
    self.positveButton.clipsToBounds = YES;
    self.positveButton.layer.cornerRadius = 5.0;
    
    if(self.isSeriousIll){
        self.title = @"大病医保";
    }
    if(self.isResidentTreatment){
        self.title = @"城乡居民医疗";
    }
    if(self.isResidentPension){
        self.title = @"城乡居民养老";
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/**
 否

 @param sender 取消在线缴费
 */
- (IBAction)cancelButtonClick:(UIButton *)sender {
    
    if (self.isResidentPension) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[YWQueryWIthYearVC class]]) {
                YWQueryWIthYearVC *vc = (YWQueryWIthYearVC *)controller;
                [self.navigationController popToViewController:vc animated:YES];
                
            }
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isResidentPension) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[YWQueryWIthYearVC class]]) {
                YWQueryWIthYearVC *vc = (YWQueryWIthYearVC *)controller;
                [self.navigationController popToViewController:vc animated:YES];
                
            }
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/**
 是

 @param sender 是
 */
- (IBAction)positiveButtonClick:(UIButton *)sender {
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"year"] = self.year;
    param[@"shbzh"] = self.shbzh;
    param[@"name"] = self.name;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    
    NSString *url = @"";
    if(self.isResidentTreatment){
        url = [NSString stringWithFormat:@"%@/insured/get/cxjmyljkxx",HOST_TEST];
    }else if(self.isSeriousIll){
        url = [NSString stringWithFormat:@"%@/insured/get/dbbxjkxx",HOST_TEST];
    }else if(self.isResidentPension){
        url = [NSString stringWithFormat:@"%@/insured//get/cxshjmyljkxx",HOST_TEST];
    }
   
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSLog(@"dictData=====%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            
            if(self.isSeriousIll){//大病保险
                NSLog(@"大病保险");
                
                YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
                paymentOrderVC.jfje = dictData[@"data"][@"jkje"];
                paymentOrderVC.ybjkdh = dictData[@"data"][@"jkdh"];
                paymentOrderVC.ywlb = dictData[@"data"][@"ywlb"];
                paymentOrderVC.shbzh = self.shbzh;
                paymentOrderVC.isSeriousIll = YES;
                [self.navigationController pushViewController:paymentOrderVC animated:YES];
            }else if(self.isResidentTreatment){//城乡居民医疗
                NSLog(@"城乡居民医疗");
                
                YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
                paymentOrderVC.jfje = dictData[@"data"][@"jfje"];
                paymentOrderVC.ybjkdh = dictData[@"data"][@"ybjkdh"];
                paymentOrderVC.ywlb = dictData[@"data"][@"ywlb"];
                paymentOrderVC.shbzh = self.shbzh;
                paymentOrderVC.isResidentTreatment = YES;
                [self.navigationController pushViewController:paymentOrderVC animated:YES];
            }else if(self.isResidentPension){
                
                NSLog(@"城乡居民养老");
                if ([dictData[@"data"][@"ywlsh"] isEqualToString:@""]) {
                    [MBProgressHUD showError:@"此人暂无支付订单,无需支付."];
                    return ;
                }
                YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
                paymentOrderVC.jfje = dictData[@"data"][@"jfje"];
                paymentOrderVC.ybjkdh = dictData[@"data"][@"ywlsh"];
                paymentOrderVC.ywlb = dictData[@"data"][@"ywlb"];
                paymentOrderVC.shbzh = self.shbzh;
                paymentOrderVC.isResidentPension = YES;
                [self.navigationController pushViewController:paymentOrderVC animated:YES];
            }
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


@end
