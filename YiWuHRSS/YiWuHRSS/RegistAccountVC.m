//
//  RegistAccountVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistAccountVC.h"
#import "RegistFinishVC.h"
#import "LoginXYVC.h"
#import "RegistHttpBL.h"
#import "CountDownService.h"
#import "UserBean.h"

#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版


@interface RegistAccountVC()<RegistHttpBLDelegate,CountDownServiceDelegate,UITextFieldDelegate>{
    RegistHttpBL    *registHttpBL;
    BOOL            _showpass;
    BOOL            _showconfirm;
    NSString        *code;
    NSString        *phone;
    BOOL            hasnet;
}

@end

@implementation RegistAccountVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
    
    if (![Util IsStringNil:self.Label_title]) {
        self.Label_card.text = self.Label_title ;
    }
    _showpass = NO;
    _showconfirm = NO;
    self.isagree = YES;
    [self.InputPass setSecureTextEntry:YES];
    [self.InputConfirm setSecureTextEntry:YES];
    registHttpBL = [RegistHttpBL sharedManager];
    registHttpBL.delegate = self;
    
    self.InputMobile.delegate = self;
    self.InputPass.delegate = self;
    self.InputCode.delegate = self;
    
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
- (void)showLoadingUIwithMsg:(NSString *)msg{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = msg;
}

#pragma mark - 页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
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

#pragma mark - 页面消失，进入后台不显示该页面，关闭定时器
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 关闭定时器
    [[CountDownService sharedManager] countDownStop];
    self.BtnSendCode.enabled = YES;
    self.BtnSendCode.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.BtnSendCode setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.BtnSendCode.userInteractionEnabled = YES;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([Util IsStringNil:string])
    {
        return YES;
    }
    
    NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
    for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
        unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
        // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
        if (character==32) return NO;
    }
    
    return YES;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 注册按钮点击事件
- (IBAction)OnClickNextAction:(id)sender {
    self.mobile = self.InputMobile.text;
    NSString *pass   = self.InputPass.text;
    NSString *confirm = self.InputConfirm.text;
    NSString *mobilemsg = [Util IsPhone:self.mobile];
    NSString *passmsg = [Util IsPassword:pass];
    NSString *confirmmsg = [Util IsPassword:confirm];
    if (self.mobile.length==0) {
        [MBProgressHUD showError:@"请输入11位手机号码"];
        return;
    }
    if (pass.length==0) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    if (confirm.length==0) {
        [MBProgressHUD showError:@"请输入确认密码"];
        return;
    }
    if (![mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
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
    if (![confirmmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"确认密码必须为6-18位数字+字母的组合，请重新输入";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    NSString *inputcode = self.InputCode.text;
    if ([Util IsStringNil:inputcode]) {
        [MBProgressHUD showError:@"验证码不能为空"];
        return;
    }

    if (!self.isagree) {
        [MBProgressHUD showError:@"请阅读并同意软件许可及服务协议"];
        return;
    }
    if (hasnet) {
        [self showLoadingUIwithMsg:@"注册中"];
        NSString *md5psd = [Util MD5:pass];
        NSString *md5confirm = [Util MD5:confirm];
        self.nextButton.userInteractionEnabled = NO;
        [registHttpBL RegisterUserHttp:self.bean.name password:md5psd againpsd:md5confirm cardType:self.type shbzh:self.bean.shbzh bankCard:self.bean.bankCard cardno:self.bean.cardno appMobile:self.mobile andvalidCode:inputcode];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
//    RegistFinishVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistFinishVC"];
//    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 发送验证码的按钮点击事件
- (IBAction)OnClickSendCodeBtn:(id)sender {
    // 检查数据录入    
    NSString *mobileNum = self.InputMobile.text;
    NSString *pass   = self.InputPass.text;
    NSString *confirm = self.InputConfirm.text;
    if (mobileNum.length==0) {
        [MBProgressHUD showError:@"请输入11位手机号"];
        return;
    }
    if (pass.length==0) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    if (confirm.length==0) {
        [MBProgressHUD showError:@"请输入确认密码"];
        return;
    }
    NSString *mobilemsg = [Util IsPhone:mobileNum];
    if (![mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
    }
    if (hasnet) {
        // 执行接口调用 调用产生验证码接口函数
        RegistHttpBL *registeBL = [RegistHttpBL sharedManager];
        registeBL.delegate = self;
        [registeBL requestSMSCode:mobileNum andmessage_type:@"2"];
        
        // 发送验证码按钮灰显
        self.BtnSendCode.enabled = NO;
        self.BtnSendCode.userInteractionEnabled = NO;
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

    self.BtnSendCode.titleLabel.font = [UIFont systemFontOfSize:ziti];
//    [self.BtnSendCode setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
    [self.BtnSendCode setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
    
    self.BtnSendCode.enabled = NO;
    self.BtnSendCode.userInteractionEnabled = NO;
}

#pragma mark - 倒计时结束时回调
- (void)onTimeFinish{
    self.BtnSendCode.enabled = YES;
    self.BtnSendCode.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.BtnSendCode setTitleColor:[UIColor colorWithHex:0x249dee] forState:UIControlStateNormal];
    [self.BtnSendCode setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.BtnSendCode.userInteractionEnabled = YES;
}


#pragma mark - 显示密码的点击事件
- (IBAction)OnClickShowPass:(id)sender {
    _showpass = !_showpass;
    [self.InputPass becomeFirstResponder];
    if (_showpass) {
        [self.BtnShowPass setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        [self.InputPass setSecureTextEntry:YES];
    }else{
        [self.InputPass setSecureTextEntry:NO];
        [self.BtnShowPass setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
    }
}

#pragma mark - 注册成功的接口回调
-(void)RegistAccountSucess:(UserBean *)bean{
    
    self.nextButton.userInteractionEnabled = YES;
    self.HUD.hidden =YES;
    self.psd = self.InputPass.text;
//    UserBean *bean = List[0];//留着下次保存信息的时候使用，这次仅仅是注释掉
    RegistFinishVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistFinishVC"];
    [VC setValue:self.mobile forKey:@"mobile"];
    [VC setValue:self.Label_title forKey:@"Label_title"];
    [VC setValue:self.psd forKey:@"psd"];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)RegistAccountFail:(NSString *)error{
    self.nextButton.userInteractionEnabled = YES;
    [MBProgressHUD showError:error];
    self.HUD.hidden =YES;
}

#pragma mark - 获取验证码回调
-(void)requestSMSCodeSucess:(SMSCodeBean*)bean{
    DMLog(@"请求验证码成功！");
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
    self.BtnSendCode.enabled = YES;
    self.BtnSendCode.userInteractionEnabled = YES;
}

#pragma mark - 同意按钮点击事件
- (IBAction)AgreeBtnClicked:(id)sender {
    self.isagree = !self.isagree;
    if (self.isagree) {
        [self.agreebtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateNormal];
    }else{
        [self.agreebtn setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }
}

#pragma mark - 软件许可及服务协议点击事件
- (IBAction)XYBtnClicked:(id)sender {
    DMLog(@"点击了软件许可及服务协议按钮");
    LoginXYVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginXYVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 显示确认密码按钮点击事件
- (IBAction)OnClickedShowConfirm:(id)sender {
    _showconfirm = !_showconfirm;
    [self.InputConfirm becomeFirstResponder];
    if (_showpass) {
        [self.BtnShowConfirm setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        [self.InputConfirm setSecureTextEntry:YES];
    }else{
        [self.InputConfirm setSecureTextEntry:NO];
        [self.BtnShowConfirm setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
    }
}

@end
