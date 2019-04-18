//
//  FindPsdVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/25.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "FindPsdVC.h"
#import "SetPassVC.h"
#import "CountDownService.h"
#import "RegistHttpBL.h"
#import "LoginHttpBL.h"
#import "LoginVC.h"


#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key
//LOGIN_ID_NUMBER
#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版


@interface FindPsdVC ()<CountDownServiceDelegate,RegistHttpBLDelegate,LoginHttpBLDelegate>{
     BOOL                hasnet;
}

@property(nonatomic, strong)   MBProgressHUD    *HUD;
@property(nonatomic, strong)     NSString       *smscode;
@property(nonatomic, strong)     NSString       *phone;
@property (weak, nonatomic) IBOutlet UIButton *isSeeButton;
@property (nonatomic, strong) LoginHttpBL      *loginHttpBL;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;//提示Label


@end

@implementation FindPsdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"重置密码";
    HIDE_BACK_TITLE;
    self.loginHttpBL = [LoginHttpBL sharedManager];
    self.loginHttpBL.delegate = self;
    self.psw.secureTextEntry = YES;
    self.mobile.text = [CoreArchive strForKey:LOGIN_APP_MOBILE];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    [self afn];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"请求验证码中";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

#pragma mark -  页面消失，进入后台不显示该页面，关闭定时器
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 关闭定时器
    [[CountDownService sharedManager] countDownStop];
    self.codebtn.enabled = YES;
    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.codebtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.codebtn.userInteractionEnabled = YES;
}

- (void)dealloc{
    DMLog(@"销毁定时器");
    [[CountDownService sharedManager] countDownStop];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 发送验证码点击事件
- (IBAction)codeBtnClicked:(id)sender {
    
    //首先获取用户手机号
    [self getMobileNumber];
}

#pragma mark -  找回密码验证身份接口回调函数
-(void)verifySFSucess:(NSString*)message{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:message];
    // 检查数据录入
    NSString *mobileNum = self.phone;
    NSString *mobilemsg = [Util IsPhone:mobileNum];
//    if (mobileNum.length==0) {
//        [MBProgressHUD showError:@"请输入11位手机号码"];
//        return;
//    }
//    if (![mobilemsg isEqualToString:@"OK"]) {
//        [MBProgressHUD showError:mobilemsg];
//        return;
//    }
    // 执行接口调用 调用产生验证码接口函数
    if (hasnet) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            RegistHttpBL *registeBL = [RegistHttpBL sharedManager];
            registeBL.delegate = self;
            [self showLoadingUI];
            [registeBL requestSMSCode:mobileNum andmessage_type:@"1"];
            
            // 发送验证码按钮灰显
            self.codebtn.enabled = NO;
            self.codebtn.userInteractionEnabled = NO;
        });
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }    
}

-(void)verifySFFail:(NSString *)error{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:error];
}

#pragma mark - 下一步按钮点击事件
- (IBAction)nextBtnClicked:(id)sender {
    NSString *mobileNum = self.mobile.text;
    NSString *mobilemsg = [Util IsPhone:mobileNum];
//    if (mobileNum.length==0) {
//        [MBProgressHUD showError:@"请输入11位手机号码"];
//        return;
//    }
//    if (![mobilemsg isEqualToString:@"OK"]) {
//        [MBProgressHUD showError:mobilemsg];
//        return;
//    }
    NSString *shbzh = self.idnumber.text;
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入身份证号码"];
        return;
    }
    
    
    NSString *pass   = self.psw.text;
    NSString *passmsg = [Util IsPassword:pass];
    if (pass.length==0) {
        [MBProgressHUD showError:@"请输入6-18位密码"];
        return ;
    }
    
    if (![passmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = passmsg;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    
    NSString *inputcode = self.code.text;
    if ([Util IsStringNil:inputcode]) {
        [MBProgressHUD showError:@"验证码不能为空"];
        return;
    }
    
    if (hasnet) {
        [self showLoadingSaveUI];
        NSString *md5psd = [Util MD5:pass];
        [self.loginHttpBL resetLoginPsdWith:self.idnumber.text andnewpsd:md5psd andvalidCode:self.code.text];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
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

    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:ziti];
//    [self.codebtn setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
    [self.codebtn setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
//    self.codebtn.adjustsImageWhenHighlighted = NO;
    self.codebtn.enabled = NO;
    self.codebtn.userInteractionEnabled = NO;
}

// 倒计时结束时回调
- (void)onTimeFinish{
    self.codebtn.enabled = YES;
    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.codebtn setTitleColor:[UIColor colorWithHex:0x249dee] forState:UIControlStateNormal];
    [self.codebtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.codebtn.userInteractionEnabled = YES;
}

#pragma mark -  短信验证接口回调
-(void)requestSMSCodeSucess:(SMSCodeBean *)bean{
    DMLog(@"验证码发送成功");
    self.HUD.hidden = YES;
    [MBProgressHUD showError:@"验证码发送成功！"];
    self.smscode = bean.validCode;
    self.phone = bean.mobileNo;
    
    // 执行倒计时处理
    [[CountDownService sharedManager] countDownStart:self];
    
    //获取验证码成功，之前输入的内容不可以进行修改
    self.mobile.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    self.idnumber.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    self.psw.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    self.mobile.userInteractionEnabled = NO;
    self.idnumber.userInteractionEnabled = NO;
    self.psw.userInteractionEnabled =   NO;
    
    self.mobile.text = self.mobile.text;
    self.idnumber.text = self.idnumber.text;
    self.psw.text = self.psw.text;

    
}

-(void)requestSMSCodeFail:(NSString *)error{
    self.HUD.hidden = YES;
    DMLog(@"验证码发送失败");
    //获取验证码失败，之前输入的内容不可以进行修改
    self.mobile.userInteractionEnabled = YES;
    self.mobile.textColor = [UIColor colorWithHex:0x333333];
    self.idnumber.userInteractionEnabled = YES;
    self.idnumber.textColor = [UIColor colorWithHex:0x333333];
    self.psw.userInteractionEnabled =   YES;
    self.psw.textColor = [UIColor colorWithHex:0x333333];
    
    [MBProgressHUD showError:error];
}

#pragma mark -  重置密码接口回调
-(void)resetLoginPsdSucceed:(NSString*)message{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:message];
    // 返回登录界面
    NSArray *temArray = self.navigationController.viewControllers;
    
    for(UIViewController *temVC in temArray)
        
    {
        if ([temVC isKindOfClass:[YWLoginVC class]])
            
        {
            [self.navigationController popToViewController:temVC animated:YES];
        }
    }
}

-(void)resetLoginPsdFailed:(NSString *)error{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:error];
}


/**
 密码是否可见

 @param sender 是否可以见按钮
 */
- (IBAction)isSeeButtonClick:(UIButton *)sender {
    
    self.isSeeButton.selected = !self.isSeeButton.selected;
    if(self.isSeeButton.selected){
        self.psw.secureTextEntry = NO;
    }else{
        self.psw.secureTextEntry = YES;
    }
}




/**
 *  显示加载中动画
 */
- (void)showLoadingSaveUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"重置密码中";
}

#pragma mark - 获取用户手机号
/**
 *  忘记密码--获取用户手机号
 */
-(void)getMobileNumber{
    
    
    // 检查数据录入
    NSString *shbzh = self.idnumber.text;
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入身份证号"];
        return;
    }
    
    //密码校验
    NSString *pass   = self.psw.text;
    NSString *passmsg = [Util IsPassword:pass];
    if (pass.length==0) {
        [MBProgressHUD showError:@"请输入6-18位密码"];
        return ;
    }
    
    if (![passmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = passmsg;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    
    if (hasnet) {
        
        [self showLoadingUI];
        [self validInfo];
        
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return;
    }
    
    
    
}

#pragma mark - 发送验证码
-(void)validInfo{
    
    NSString * shbzhAES = aesEncryptString(self.idnumber.text, AESEncryptKey);

    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"shbzh"] = shbzhAES;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    NSString *url = [NSString stringWithFormat:@"%@/userServer/resetPassword/valid/aes",HOST_TEST];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSString * resultCode = resultDict[@"resultCode"];
        
        if([resultCode integerValue]==200){
            self.phone = resultDict[@"data"][@"appMobile"];
            
            NSString * phoneNumPre = [self.phone substringToIndex:3];
            NSString * phoneNumRear = [self.phone substringFromIndex:8];
            NSString * phoneNum = [NSString stringWithFormat:@"%@****%@",phoneNumPre,phoneNumRear];
            DMLog(@"phoneNumPre==%@",phoneNumPre);
            DMLog(@"phoneNumRear==%@",phoneNumRear);
            self.tipsLabel.text = [NSString stringWithFormat:@"短信已发送至%@的手机号码",phoneNum];
            self.tipsLabel.hidden = NO;
            
            [self verifySFSucess:resultDict[@"message"]];
        }else{
            [self verifySFFail:resultDict[@"message"]];
        }
        DMLog(@"忘记密码--获取用户手机号==resultDict%@",resultDict);
    } failure:^(NSError *error) {
        [self verifySFFail:@"服务暂不可用，请稍后重试"];
    }];
}



@end
