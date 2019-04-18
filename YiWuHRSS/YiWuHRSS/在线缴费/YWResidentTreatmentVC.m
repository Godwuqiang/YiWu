//
//  YWResidentTreatmentVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/25.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWResidentTreatmentVC.h"
#import "YWRegistSuccessVC.h"
#import "YWRegistFailVC.h"
#import "YWPaymentOrderVC.h"

@interface YWResidentTreatmentVC ()

/** 参保类型数组 */
@property (nonatomic,strong) NSMutableArray<PickerViewModel *> * cblxArray;
/** 选择的参保类型档次 */
@property (nonatomic,strong) PickerViewModel * selectedCBLX;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;


@end

@implementation YWResidentTreatmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"城乡居民医疗";
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5.0;
    self.nameLabel.text = self.name;
    self.idNumberLabel.text = self.shbzh;
    self.yearLabel.text = [NSString stringWithFormat:@"%@年",self.year];
    if([self.dzbz integerValue]==1){
        
        self.statusLabel.text = @"已参保";
        
    }else if ([self.dzbz integerValue]==2){
        
        self.statusLabel.text = @"待缴费";
        
    }else if ([self.dzbz integerValue]==3){
        
        self.statusLabel.text = @"已到账";
    }
    
    self.cblxArray = [NSMutableArray array];
    PickerViewModel *model0 = [[PickerViewModel alloc]init];
    model0.title = self.cblxDict[@"0"];
    model0.extraObj = @"0";
    [self.cblxArray addObject:model0];
    PickerViewModel *model1 = [[PickerViewModel alloc]init];
    model1.title = self.cblxDict[@"25"];
    model1.extraObj = @"25";
    [self.cblxArray addObject:model1];
    PickerViewModel *model2 = [[PickerViewModel alloc]init];
    model2.title = self.cblxDict[@"26"];
    model2.extraObj = @"26";
    [self.cblxArray addObject:model2];
    if([self.type isEqualToString:@"0"]){
        self.typeLabel.text = @"不参保";
    }else if ([self.type isEqualToString:@"25"]){
        self.typeLabel.text = @"低档";
    }else if ([self.type isEqualToString:@"26"]){
        self.typeLabel.text = @"中档";
    }
    
    //默认参保类型
    self.selectedCBLX = [[PickerViewModel alloc]init];
    for (PickerViewModel * model in self.cblxArray) {
        if([model.extraObj isEqualToString:self.type]){
            self.selectedCBLX = model;
            NSLog(@"默认参保类型为：%@",self.selectedCBLX.extraObj);
        }
    }
    //是否来自在线付款入口
    if(self.isFromGotoPay){
        [self.confirmButton setTitle:@"在线缴费" forState:UIControlStateNormal];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"paymentFinished" object:nil];
}

/**
 确认参保

 @param sender 确认参保
 */
- (IBAction)comfirmButton:(UIButton *)sender {
        
    if(self.isFromGotoPay){
        [self gotoPay];
        return;
    }
    
    
    NSLog(@"确认参保中......");
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"cblx"] = self.selectedCBLX.extraObj;
    param[@"year"] = self.year;
    param[@"shbzh"] = self.shbzh;
    param[@"name"] = self.name;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;

    NSString *url = [NSString stringWithFormat:@"%@/insured/cxjmylcb",HOST_TEST];
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        if([dictData[@"resultCode"] integerValue]==200){
            DMLog(@"参保结果==%@",dictData);
            
            YWRegistSuccessVC * registSuccessVC = [[YWRegistSuccessVC alloc]init];
            registSuccessVC.shbzh = self.shbzh;
            registSuccessVC.name = self.name;
            registSuccessVC.year = self.year;
            registSuccessVC.isResidentTreatment = YES;
            [self.navigationController pushViewController:registSuccessVC animated:YES];
        }else{
            YWRegistFailVC * registfailedVC = [[YWRegistFailVC alloc]init];
            registfailedVC.isResidentTreatment = YES;
            registfailedVC.reson = dictData[@"message"];
            [self.navigationController pushViewController:registfailedVC animated:YES];
        }
    } failure:^(NSError *error) {
        
        self.HUD.hidden = YES;
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

/**
 参保类型按钮点击

 @param sender 参保类型
 */
- (IBAction)cblxButtonClick:(UIButton *)sender {
    
    EPPickerView *pikcerView = [EPPickerView showPickerViewWithNumberOfLevel:1];
    pikcerView.datas = self.cblxArray;
    pikcerView.selectOptionFinishBlock = ^(NSArray<PickerViewModel *> *selectedOptionArray) {
        self.typeLabel.text = [selectedOptionArray firstObject].title;
        self.selectedCBLX = [selectedOptionArray firstObject];
    };
}


/**
 在线缴费
 */
-(void)gotoPay{
    
    NSLog(@"在线缴费中......");
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"year"] = self.year;
    param[@"shbzh"] = self.shbzh;
    param[@"name"] = self.name;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    
    NSString *url = [NSString stringWithFormat:@"%@/insured/get/cxjmyljkxx",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSLog(@"dictData=====%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
    
            NSLog(@"城乡居民医疗");
            YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
            paymentOrderVC.jfje = dictData[@"data"][@"jfje"];
            paymentOrderVC.ybjkdh = dictData[@"data"][@"ybjkdh"];
            paymentOrderVC.ywlb = dictData[@"data"][@"ywlb"];
            paymentOrderVC.shbzh = self.shbzh;
            paymentOrderVC.isResidentTreatment = YES;
            [self.navigationController pushViewController:paymentOrderVC animated:YES];
         
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        self.HUD.hidden = YES;
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

#pragma mark - showLoadingUI
/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.label.text = @"加载中";
    self.HUD.hidden = NO;
}

@end
