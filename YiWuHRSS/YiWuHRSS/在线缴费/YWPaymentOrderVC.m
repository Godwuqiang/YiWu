//
//  YWPaymentOrderVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWPaymentOrderVC.h"
#import "AlipaySDK.h"
#import "YWPayResultViewController.h"
#import "DTFPaymentPasswordView.h"

@interface YWPaymentOrderVC ()
@property (weak, nonatomic) IBOutlet UILabel *jfjeLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;
@property (weak, nonatomic) IBOutlet UIButton *ybButton;
@property (weak, nonatomic) IBOutlet UIButton *alipayButton;

/** payType:支付宝1，医保账户余额2 */
@property (nonatomic,strong) NSString * payType;
/** 支付密码输入页面 */
@property (nonatomic ,strong) DTFPaymentPasswordView * paymentView;



@end

@implementation YWPaymentOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"支付订单";
    self.payType = @"";
    self.alipayButton.selected = NO;
    self.ybButton.selected = NO;
    
    
    self.projectNameLabel.text = self.ywlb;
    self.orderNumerLabel.text = self.ybjkdh;
    NSString * jfjeString = [NSString stringWithFormat:@"%.2f",[self.jfje doubleValue]];
    self.jfjeLabel.text = jfjeString;
    [self.confirmButton setTitle:[NSString stringWithFormat:@"确认支付¥%@",jfjeString] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFinished:) name:@"paymentFinished" object:@"1"];
    
    //如果是c医疗和养老不显示余额支付
    if (self.isResidentTreatment || self.isResidentPension) {
        self.yueView.hidden = YES;
        self.payType = @"1";
        self.alipayButton.selected = YES;
        self.ybButton.selected = NO;
    }
}

/**
 支付宝支付点击

 @param sender 支付宝支付
 */
- (IBAction)alipayButtonClick:(UIButton *)sender {
    
    self.payType = @"1";
    self.alipayButton.selected = YES;
    self.ybButton.selected = NO;
    NSLog(@"支付宝支付点击");
}


/**
 医保账户余额支付

 @param sender 医保账户支付
 */
- (IBAction)ybButtonClick:(UIButton *)sender {
    
    self.payType = @"2";
    self.alipayButton.selected = NO;
    self.ybButton.selected = YES;
    NSLog(@"医保余额支付点击");
}

#pragma mark  - 支付宝支付完成 - 回调到本APP - 接收到APP的通知
-(void)payFinished:(NSNotification *)notice{
    
    if(notice.userInfo==nil){
        NSLog(@"支付完成-通知内容为空");
        YWPayResultViewController * resultVC = [[YWPayResultViewController alloc]init];
        if(self.isResidentTreatment){
            resultVC.isResidentTreatment = YES;
        }else if (self.isSeriousIll){
            resultVC.isSeariousIll = YES;
        }
        resultVC.succeed = NO;
        NSString * reason = [CoreArchive strForKey:YW_ALIPAY_FAILED_REASON];
        resultVC.reason = reason;
        [self.navigationController pushViewController:resultVC animated:YES];
    }else{
        NSLog(@"支付完成-通知内容为非空");
        NSDictionary * payResponseDict = notice.userInfo[@"alipay_trade_app_pay_response"];
        NSString * tradeNo = payResponseDict[@"trade_no"];
        [self alipayFinishedCallbackWith:tradeNo];
    }
    DMLog(@"支付宝支付完成 - 回调到本APP - 接收到APP的通知 -- %@",notice.userInfo);
}
/**
 支付按钮点击事件

 @param sender 支付
 */
- (IBAction)payButtonClick:(UIButton *)sender {
    
    if(self.alipayButton.selected){
        [self alipayAction];
    }else if (self.ybButton.selected){
        [self ybAction];
    }else{
        [MBProgressHUD showError:@"请选择支付方式"];
    }
}



/** 支付宝支付 */
-(void)alipayAction{
    
    NSString *appScheme = @"YiWuSBIosApp";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"outTradeNo"] = self.ybjkdh;
    param[@"totalAmount"] = self.jfje;
    param[@"app_version"] = version;
    param[@"device_type"] = @"2";
//    param[@"orderType"] = self.ywlb;
    
    if(self.isSeriousIll){//大病
        param[@"orderType"] = @"3";
    }else if (self.isResidentTreatment){//居民医疗
        param[@"orderType"] = @"2";
    }else if (self.isResidentPension){//居民养老
        param[@"orderType"] = @"1";
        param[@"payerIdCard"] = self.shbzh;
        
    }else{
        param[@"orderType"] = @"4";
    }
    
    
    
    NSString *url = [NSString stringWithFormat:@"%@/alipay/tradeQuery",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    [CoreArchive setStr:self.ybjkdh key:YW_ALIPAY_TRADE_NUM];
    DMLog(@"YW_ALIPAY_TRADE_NUM==%@",[CoreArchive strForKey:YW_ALIPAY_TRADE_NUM]);
    
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"点击跳转支付宝==%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            //NOTE: 调用支付结果开始支付
            [[AlipaySDK defaultService] payOrder:dictData[@"data"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
                NSLog(@"支付回调");
            }];
        }
    } failure:^(NSError *error) {
    }];
    
}

/** 医保账户余额支付 */
-(void)ybAction{
    
    NSLog(@"支付密码输入页面");
    //支付密码输入页面
    DTFPaymentPasswordView *paymentPasswordView = [[NSBundle mainBundle] loadNibNamed:@"DTFPaymentPasswordView" owner:nil options:nil].firstObject;
    paymentPasswordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.paymentView = paymentPasswordView;
    self.paymentView.nav = self.navigationController;
    __weak typeof(self)weakSelf = self;
    self.paymentView.completeBlock = ^(NSString *password) {
        
        [weakSelf ybPayWithPassword:password];
    };
    
    [self.navigationController.view addSubview:paymentPasswordView];
    
    
    //支付密码输入页面弹出动画
    CGRect beforeFrame = self.paymentView.frame;
    self.paymentView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y + 300, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.paymentView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.paymentView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y - 300, afterFrame.size.width, afterFrame.size.height);
    }];
}

-(void)ybPayWithPassword:(NSString *)password{
    
    NSString *appScheme = @"YiWuSBIosApp";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"outTradeNo"] = self.ybjkdh;
    param[@"app_version"] = version;
    param[@"device_type"] = @"2";
    param[@"orderType"] = self.ywlb;
    param[@"payPwd"] = aesEncryptString(password, AESEncryptKey);
    
    
    NSString *url = [NSString stringWithFormat:@"%@/insured/payPassword/check",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    [CoreArchive setStr:self.ybjkdh key:YW_ALIPAY_TRADE_NUM];
    DMLog(@"YW_ALIPAY_TRADE_NUM==%@",[CoreArchive strForKey:YW_ALIPAY_TRADE_NUM]);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"支付结果==%@",dictData);
        YWPayResultViewController * resultVC = [[YWPayResultViewController alloc]init];
        if(self.isResidentTreatment){
            resultVC.isResidentTreatment = YES;
        }else if (self.isSeriousIll){
            resultVC.isSeariousIll = YES;
        }
        if([dictData[@"resultCode"] integerValue]==200){
            resultVC.succeed = YES;
            resultVC.reason = @"";
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
            
            resultVC.succeed = NO;
            resultVC.reason = dictData[@"message"];
            [MBProgressHUD showError:dictData[@"message"]];
            [self.navigationController pushViewController:resultVC animated:YES];
        }
    } failure:^(NSError *error) {
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



/**
 支付宝支付完成的回到

 @param trade_no 支付平台账单号
 */
-(void)payFinishedCallbackWith:(NSString *)trade_no{
    
    NSString * tradeNum = [CoreArchive strForKey:YW_ALIPAY_TRADE_NUM];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"shbzh"] = self.shbzh;//身份证号
    param[@"ybjkdh"] = tradeNum;//医保缴款单号
    param[@"jkje"] = self.jfje;//缴款金额
    param[@"zfptzdh"] = trade_no;//支付平台账单号
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    if(self.isSeriousIll){
        param[@"jkdh"] = tradeNum;
    }
    
    
    NSString *url = @"";
    if(self.isResidentTreatment){
        url = [NSString stringWithFormat:@"%@/insured/get/cxjmyljkjg",HOST_TEST];
    }else if (self.isSeriousIll){
        url = [NSString stringWithFormat:@"%@/insured/get/dbbxjkjg",HOST_TEST];
    }
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"支付结果==%@",dictData);
        YWPayResultViewController * resultVC = [[YWPayResultViewController alloc]init];
        if(self.isResidentTreatment){
            resultVC.isResidentTreatment = YES;
        }else if (self.isSeriousIll){
            resultVC.isSeariousIll = YES;
        }
        if([dictData[@"resultCode"] integerValue]==200){
            resultVC.succeed = YES;
            resultVC.reason = @"";
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
            
            resultVC.succeed = NO;
            resultVC.reason = dictData[@"message"];
            [MBProgressHUD showError:dictData[@"message"]];
            [self.navigationController pushViewController:resultVC animated:YES];
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
 支付宝支付完成的回到
 
 @param trade_no 支付平台账单号
 */
-(void)alipayFinishedCallbackWith:(NSString *)trade_no{
    
    NSString * tradeNum = [CoreArchive strForKey:YW_ALIPAY_TRADE_NUM];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"outTradeNo"] = tradeNum;//医保缴款单号
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    NSString *url = [NSString stringWithFormat:@"%@/alipay/get/tradeInfo",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"支付结果==%@",dictData);
        YWPayResultViewController * resultVC = [[YWPayResultViewController alloc]init];
        if(self.isResidentTreatment){
            resultVC.isResidentTreatment = YES;
        }else if (self.isSeriousIll){
            resultVC.isSeariousIll = YES;
        }
        if([dictData[@"resultCode"] integerValue]==200){
            resultVC.succeed = YES;
            resultVC.reason = @"";
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
            
            resultVC.succeed = NO;
            resultVC.reason = dictData[@"message"];
            [MBProgressHUD showError:dictData[@"message"]];
            [self.navigationController pushViewController:resultVC animated:YES];
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





#pragma mark - showLoadingUI
/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.label.text = @"支付中...";
    self.HUD.hidden = NO;
}

@end
