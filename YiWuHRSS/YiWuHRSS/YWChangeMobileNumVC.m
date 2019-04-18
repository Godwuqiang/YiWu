//
//  YWChangeMobileNumVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/21.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWChangeMobileNumVC.h"
#import "RegistHttpBL.h"
#import "CountDownService.h"

#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版
#define URL_UPDATEAPPMOBILE        @"/userServer/updateAppMobile.json"                   //修改注册手机号

@interface YWChangeMobileNumVC ()<UITextFieldDelegate, RegistHttpBLDelegate, CountDownServiceDelegate> {
    
    RegistHttpBL    *registHttpBL;
    BOOL   hasnet;
    
    NSString        *code;
    NSString        *phone;
}

// 控件
@property(nonatomic, strong) MBProgressHUD    *HUD;

@end

@implementation YWChangeMobileNumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"修改注册手机号";
    
    self.nameLB.text = [CoreArchive strForKey:LOGIN_NAME];
    self.oldPhoneLB.text = [CoreArchive strForKey:LOGIN_APP_MOBILE];
    
    NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
    NSString *sbh2 = [sbh substringToIndex:12];
    NSString *sbh3 = [NSString stringWithFormat:@"%@******",sbh2];
    self.IDNumberLB.text = [Util HeadStr:sbh3 WithNum:0];
    
    
    self.validCodeTF.delegate = self;
    self.phoneTF.delegate = self;
    
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5.0;
    
    [self afn];
}

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            hasnet = YES;
        }else{
            hasnet = NO;
        }
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self.view setFrame:CGRectMake(0, -120, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    
    [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    return YES;
}

#pragma mark - 发送验证码
- (IBAction)validCodeButtonClick:(id)sender {
    
    
    NSString *mobileNum = self.phoneTF.text;
    if (mobileNum.length==0) {
        [MBProgressHUD showError:@"请输入11位手机号"];
        return;
    }
    NSString *mobilemsg = [Util IsPhone:mobileNum];
    if (![mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
    }
    
    if ([self.phoneTF.text isEqualToString:[CoreArchive strForKey:LOGIN_APP_MOBILE]]) {
        
        [MBProgressHUD showError:@"修改的手机号与原手机号相同，请重新输入其他手机号！"];
        return;
    }
    
    
    if (hasnet) {
        // 执行接口调用 调用产生验证码接口函数
        RegistHttpBL *registeBL = [RegistHttpBL sharedManager];
        registeBL.delegate = self;
        [registeBL requestSMSCode:mobileNum andmessage_type:@"5"];
        
        // 发送验证码按钮灰显
        self.validCodeBtn.enabled = NO;
        self.validCodeBtn.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
    
    
}

#pragma mark - 确定
- (IBAction)submitButtonClick:(id)sender {
    
    NSString *mobileNum = self.phoneTF.text;
    if (mobileNum.length==0) {
        [MBProgressHUD showError:@"请输入11位手机号"];
        return;
    }
    NSString *mobilemsg = [Util IsPhone:mobileNum];
    if (![mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
    }
    
    if (self.validCodeTF.text.length == 0) {
        [MBProgressHUD showError:@"请输入验证码"];
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"appMobile"] = self.phoneTF.text;
    param[@"validCode"] = self.validCodeTF.text;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_UPDATEAPPMOBILE];
    
    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSLog(@"修改注册手机号-%@",dictData);
        NSLog(@"修改注册手机号-message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            [MBProgressHUD showSuccess:@"修改成功~"];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else{
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
        
    }];
    
}


#pragma mark - 计时器监听
// 倒计时回调
- (void)onTimeTick:(NSInteger)hasSeconds{
    CGFloat ziti;
    if ( SCREEN_HEIGHT > 667) //6p
    {
        ziti = 13;      //
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        ziti = 12;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        ziti = 11;
    }
    else //3.5寸屏幕
    {
        ziti = 10;
    }
    
    self.validCodeBtn.titleLabel.font = [UIFont systemFontOfSize:ziti];
    //    [self.BtnSendCode setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
    [self.validCodeBtn setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
    
    self.validCodeBtn.enabled = NO;
    self.validCodeBtn.userInteractionEnabled = NO;
}

#pragma mark - 倒计时结束时回调
- (void)onTimeFinish{
    self.validCodeBtn.enabled = YES;
    self.validCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.validCodeBtn setTitleColor:[UIColor colorWithHex:0x249dee] forState:UIControlStateNormal];
    [self.validCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.validCodeBtn.userInteractionEnabled = YES;
}


#pragma mark - 获取验证码回调
-(void)requestSMSCodeSucess:(SMSCodeBean*)bean{
    
    DMLog(@"请求验证码成功！");
    
    // 提示用户已发送短信
    [MBProgressHUD showError:@"验证码已发送"];
    code = bean.validCode;
    phone = bean.mobileNo;
    // 执行倒计时处理
    [[CountDownService sharedManager] countDownStart:self];
    
}

- (void)requestSMSCodeFail:(NSString *)error{
    
    DMLog(@"短信失败的提示：%@", error);
    
    // 提示用户
    
    [MBProgressHUD showError:error];
    
    // 发送验证码按钮灰显
    self.validCodeBtn.enabled = YES;
    self.validCodeBtn.userInteractionEnabled = YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}



@end
