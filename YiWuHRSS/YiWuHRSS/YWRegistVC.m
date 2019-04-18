//
//  YWRegistVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/17.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWRegistVC.h"
#import "YWRegistZMVC.h"
#import "RegistHttpBL.h"
#import "CountDownService.h"
#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key

#define LOGIN_URL   @"userServer/register/New1/aes?"  //注册校验 义乌2.3
#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版


@interface YWRegistVC ()<UITextFieldDelegate,RegistHttpBLDelegate,CountDownServiceDelegate>{
    RegistHttpBL    *registHttpBL;
    BOOL            _showpass;
    BOOL            _showconfirm;
    NSString        *code;
    NSString        *phone;
    BOOL            hasnet;
}


@end

@implementation YWRegistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}


-(void)setupUI{
    self.title = @"注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tap];
    
    self.nameTextField.delegate = self;
    self.idTextField.delegate = self;
    self.pswTextField.delegate = self;
    self.comfirmPswTextField.delegate = self;
    self.mobileTextField.delegate = self;
    self.smsCodeTextField.delegate =self;
    
    self.seePswButton.selected = NO;
    self.seeComfirmPswButton.selected = NO;
    
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.clipsToBounds = YES;
    
    registHttpBL = [RegistHttpBL sharedManager];
    registHttpBL.delegate = self;
    
    
    [self afn];
}

-(void)back{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapView{
    
    [self.nameTextField resignFirstResponder];
    [self.idTextField resignFirstResponder];
    [self.pswTextField resignFirstResponder];
    [self.comfirmPswTextField resignFirstResponder];
    [self.mobileTextField resignFirstResponder];
    [self.smsCodeTextField resignFirstResponder];
    
}

#pragma mark - 按钮点击事件

//查看密码按钮点击事件
- (IBAction)seePswButtonClick:(UIButton *)sender {
    
    self.seePswButton.selected = !self.seePswButton.selected;
    if(self.seePswButton.selected){
        self.pswTextField.secureTextEntry = NO;
    }else{
        self.pswTextField.secureTextEntry = YES;
    }
}
//查看确认密码按钮点击事件
- (IBAction)seeComfirmPswButtonClick:(UIButton *)sender {
    self.seeComfirmPswButton.selected = !self.seeComfirmPswButton.selected;
    if(self.seeComfirmPswButton.selected){
        self.comfirmPswTextField.secureTextEntry = NO;
    }else{
        self.comfirmPswTextField.secureTextEntry = YES;
    }
}

//发送验证码按钮点击事件
- (IBAction)smsCodeButtonClick:(UIButton *)sender {
    
    DMLog(@"发送验证码按钮点击");
    [self sendSmsCode];
}
//下一步按钮点击事件
- (IBAction)nextButtonClick:(UIButton *)sender {
    
    DMLog(@"下一步按钮点击");
    
    if(self.nameTextField.text.length ==0){
        
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    
    if(self.idTextField.text.length ==0){
        
        [MBProgressHUD showError:@"请输入身份证号"];
        return;
    }

    if(self.idTextField.text.length ==18 ||self.idTextField.text.length == 15){
        
    }else{
        [MBProgressHUD showError:@"请输入正确的身份证号"];
        return;
    }
    
    if(self.pswTextField.text.length <6){
        [MBProgressHUD showError:@"设置6-18位数字+字母组合的密码"];
        return;
    }
    
    if(self.comfirmPswTextField.text.length<6){
        [MBProgressHUD showError:@"设置6-18位数字+字母组合的密码"];
        return;
    }

    
    NSString *passmsg = [Util IsPassword:self.pswTextField.text];
    NSString *confirmmsg = [Util IsPassword:self.comfirmPswTextField.text];
    
    if(self.pswTextField.text.length ==0){
        
        [MBProgressHUD showError:@"设置6-18位数字+字母组合的密码"];
        return;
    }
    
    if(self.comfirmPswTextField.text.length ==0){
        
        [MBProgressHUD showError:@"设置6-18位数字+字母组合的密码"];
        return;
    }
    
    if (![passmsg isEqualToString:@"OK"]) {
        passmsg = @"";
        [MBProgressHUD showError:@"确认密码必须为6-18位数字+字母的组合，请重新输入"];
        return ;
    }
    if (![confirmmsg isEqualToString:@"OK"]) {
        confirmmsg = @"";
        [MBProgressHUD showError:@"确认密码必须为6-18位数字+字母的组合，请重新输入"];
        return ;
    }
    
    if(![self.pswTextField.text isEqualToString:self.comfirmPswTextField.text]){
        
        [MBProgressHUD showError:@"两次输入密码不一致"];
        return;
    }
    
    if(self.mobileTextField.text.length == 0){
        [MBProgressHUD showError:@"请输入11位手机号"];
        return;
    }
    
    NSString *mobilemsg = [Util IsPhone:self.mobileTextField.text];
    if (![mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
    }
    
    if(self.smsCodeTextField.text.length == 0){
        [MBProgressHUD showError:@"请输入验证码"];
        return;
    }
    
    [self gotoRegist];
}


#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField == _idTextField){
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y-14, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _pswTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y-64, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _comfirmPswTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y-104, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _mobileTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y-164, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _smsCodeTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y-204, viewFrame.size.width, viewFrame.size.height);
        }];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField == _idTextField){
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y+14, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _pswTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y+64, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _comfirmPswTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y+104, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _mobileTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y+164, viewFrame.size.width, viewFrame.size.height);
        }];
    }else if (textField == _smsCodeTextField){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect viewFrame = self.view.frame;
            self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y+204, viewFrame.size.width, viewFrame.size.height);
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([Util IsStringNil:string])
    {
        return YES;
    }
    
    if (textField==self.pswTextField) {
        
        return YES;
    }else if(textField == self.idTextField){
        
        if(self.idTextField.text.length >=18){
            return NO;
        }
        
        NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
            if (character==32) return NO;
            if (character==79 || character==111) return NO;
            if (character < 48) return NO; // 48 unichar for 0
            if (character > 57 && character < 65) return NO; //
            if (character > 90 && character < 97) return NO;
            if (character > 122) return NO;
        }
        
        char commitChar = [string characterAtIndex:0];
        
        if (commitChar > 96 && commitChar < 123)
        {
            //小写变成大写
            
            NSString * uppercaseString = string.uppercaseString;
            
            NSString * str1 = [textField.text substringToIndex:range.location];
            
            NSString * str2 = [textField.text substringFromIndex:range.location];
            
            textField.text = [NSString stringWithFormat:@"%@%@%@",str1,uppercaseString,str2];
            
            return NO;
        }
        
        
        
    } else{
        return YES;
    }
    
    return YES;
}

#pragma mark - 登录的网络请求
/** 注册的网络请求 */
-(void)gotoRegist{
    
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    NSString * shbzhAES = aesEncryptString(self.idTextField.text, AESEncryptKey);
    NSString * appMobileAES = aesEncryptString(self.mobileTextField.text, AESEncryptKey);
    NSString * passwordAES = aesEncryptString(self.pswTextField.text, AESEncryptKey);
    NSString * password_againAES = aesEncryptString(self.comfirmPswTextField.text, AESEncryptKey);
    
    
    param[@"shbzh"] = shbzhAES;
    param[@"deviceType"] = @"2";
    param[@"appMobile"] = appMobileAES;
    param[@"validCode"] = self.smsCodeTextField.text;
    param[@"password"] = passwordAES;
    param[@"password_again"] = password_againAES;
    param[@"imei"] = [Util getuuid];
    param[@"appVersion"] = version;
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,LOGIN_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {

        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"义乌2.3注册=resultDict==%@",resultDict);
        if([resultDict[@"resultCode"] integerValue]==200){
            
            YWRegistZMVC * registZMVC  = [[YWRegistZMVC alloc]init];
            registZMVC.name = self.nameTextField.text;
            registZMVC.shbzh = self.idTextField.text;
            registZMVC.appMobile = self.mobileTextField.text;
            registZMVC.password = self.pswTextField.text;
            [self.navigationController pushViewController:registZMVC animated:YES];
            
        }else{
            [MBProgressHUD showError:resultDict[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
    
}


/** 点击发送验证码 */
-(void)sendSmsCode{
    // 检查数据录入
    NSString *mobileNum = self.mobileTextField.text;
    NSString *pass   = self.pswTextField.text;
    NSString *confirm = self.comfirmPswTextField.text;
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
        self.smsCodeButton.enabled = NO;
        self.smsCodeButton.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
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
    
    self.smsCodeButton.titleLabel.font = [UIFont systemFontOfSize:ziti];
    //    [self.BtnSendCode setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
    [self.smsCodeButton setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
    
    self.smsCodeButton.enabled = NO;
    self.smsCodeButton.userInteractionEnabled = NO;
}

#pragma mark - 倒计时结束时回调
- (void)onTimeFinish{
    self.smsCodeButton.enabled = YES;
    self.smsCodeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.smsCodeButton setTitleColor:[UIColor colorWithHex:0x249dee] forState:UIControlStateNormal];
    [self.smsCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.smsCodeButton.userInteractionEnabled = YES;
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
    self.smsCodeButton.enabled = YES;
    self.smsCodeButton.userInteractionEnabled = YES;
}


@end
