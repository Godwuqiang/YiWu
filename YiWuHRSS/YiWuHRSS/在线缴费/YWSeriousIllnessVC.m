//
//  YWSeriousIllnessVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWSeriousIllnessVC.h"
#import "YWRegistSuccessVC.h"
#import "YWRegistFailVC.h"
#import "YWPaymentOrderVC.h"


@interface YWSeriousIllnessVC ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *unpaymentLabel;

@property (weak, nonatomic) IBOutlet UIButton *onlinePaymentButton;
/** 缴费档次数组 */
@property (nonatomic,strong) NSMutableArray * jfdcArray;
/** 选择的缴费档次 */
@property (nonatomic,strong) PickerViewModel * selectedJFDC;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;

@end

@implementation YWSeriousIllnessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"大病保险";
    self.onlinePaymentButton.clipsToBounds = YES;
    self.onlinePaymentButton.layer.cornerRadius = 5.0;
    self.nameLabel.text = self.name;
    self.idNumberLabel.text = self.shbzh;
    self.yearLabel.text = self.year;
    self.statusLabel.text = self.dzbz;
    self.levelLabel.text = [NSString stringWithFormat:@"%@",self.jfdc];
    self.paymentLabel.text = self.yjje;
    self.unpaymentLabel.text = self.wjje;
    
    self.jfdcArray = [NSMutableArray array];
    
    PickerViewModel * model0 = [[PickerViewModel alloc]init];
    model0.extraObj = @"0";
    model0.title = self.jfdcDict[@"0"];
    [self.jfdcArray addObject:model0];
    
    PickerViewModel * model1 = [[PickerViewModel alloc]init];
    model1.extraObj = @"1";
    model1.title = self.jfdcDict[@"1"];
    [self.jfdcArray addObject:model1];
    
    PickerViewModel * model2 = [[PickerViewModel alloc]init];
    model2.extraObj = @"2";
    model2.title = self.jfdcDict[@"2"];
    [self.jfdcArray addObject:model2];
    
    PickerViewModel * model3 = [[PickerViewModel alloc]init];
    model3.extraObj = @"3";
    model3.title = self.jfdcDict[@"3"];
    [self.jfdcArray addObject:model3];
    
    //默认选择的参保类型
    self.selectedJFDC = [[PickerViewModel alloc]init];
    for (PickerViewModel * model in self.jfdcArray) {
        if([model.extraObj isEqualToString:self.jfdcid]){
            self.selectedJFDC = model;
        }
    }
    

    
    //来自在线缴费
    if(self.isFromGotoPay){
        [self.onlinePaymentButton setTitle:@"在线缴费" forState:UIControlStateNormal];
    }else{
        [self.onlinePaymentButton setTitle:@"确认参保" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



/**
 确认参保或者在线缴费

 @param sender 点击事件
 */
- (IBAction)onlinePaymentButtonClick:(UIButton *)sender {
    
    NSLog(@"self.selectedJFDC.extraObj===%@",self.selectedJFDC.extraObj);
    NSLog(@"self.dzbz===%@",self.dzbz);

    if(self.isFromGotoPay){
        [self gotoPay];
        return;
    }
    
    
    NSString *url = [NSString stringWithFormat:@"%@/insured/dbbxcb",HOST_TEST];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"jfdc"] = self.selectedJFDC.extraObj;
    param[@"year"] = self.year;
    param[@"shbzh"] = self.shbzh;
    param[@"name"] = self.name;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    NSLog(@"url===%@",url);
    NSLog(@"param===%@",param);
    

    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"参保结果==%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
    
            YWRegistSuccessVC * registSuccessVC = [[YWRegistSuccessVC alloc]init];
            registSuccessVC.shbzh = self.shbzh;
            registSuccessVC.name = self.name;
            registSuccessVC.year = self.year;
            registSuccessVC.isSeriousIll = YES;
            [self.navigationController pushViewController:registSuccessVC animated:YES];
        }else{
            
            YWRegistFailVC * registfailedVC = [[YWRegistFailVC alloc]init];
            registfailedVC.isSeriousIll = YES;
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
 缴费档次按钮点击事件

 @param sender 缴费档次按钮
 */
- (IBAction)jfdcButtonClick:(UIButton *)sender {
    EPPickerView *pikcerView = [EPPickerView showPickerViewWithNumberOfLevel:1];
    pikcerView.datas = self.jfdcArray;
    pikcerView.selectOptionFinishBlock = ^(NSArray<PickerViewModel *> *selectedOptionArray) {
        self.levelLabel.text = [selectedOptionArray firstObject].title;
        self.selectedJFDC = [selectedOptionArray firstObject];
    };
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

/**
 选择缴费档次都计算
 */
-(void)reloadInfo{
    [self showLoadingUI];
    
    
   
}

/**
 在线缴费
 */
-(void)gotoPay{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"year"] = self.year;
    param[@"shbzh"] = self.shbzh;
    param[@"name"] = self.name;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    
    NSString *url = [NSString stringWithFormat:@"%@/insured/get/dbbxjkxx",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSDictionary *data = dictData[@"data"];
        NSLog(@"dictData=====%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            
            YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
            paymentOrderVC.jfje = data[@"jkje"];
            paymentOrderVC.ybjkdh = data[@"jkdh"];
            paymentOrderVC.ywlb = data[@"ywlb"];
            paymentOrderVC.shbzh = self.shbzh;
            paymentOrderVC.isSeriousIll = YES;
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

@end
