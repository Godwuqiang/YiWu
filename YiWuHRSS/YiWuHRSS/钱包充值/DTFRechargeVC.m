//
//  DTFRechargeVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/11/9.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFRechargeVC.h"
#import "DTFPaymentPasswordView.h"
#import "YKFPay.h"
#import "HttpHelper.h"
#import "AESCipher.h"
#import "BdH5VC.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key
#define URL_INIT_RECHARGE   @"/smk/initializationRecharge.json"     //初始化充值页面信息接口
#define URL_RECHARGE        @"/smk/recharge.json"                   //大钱包充值接口



@interface DTFRechargeVC ()<UITextFieldDelegate>

/** 用户头像 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 姓名Label */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/** 50按钮 */
@property (weak, nonatomic) IBOutlet UIButton *fiftyButton;
/** 100按钮 */
@property (weak, nonatomic) IBOutlet UIButton *OneHundredButton;
/** 200按钮 */
@property (weak, nonatomic) IBOutlet UIButton *TwoHundredButton;
/** 输入自定义金额框 */
@property (weak, nonatomic) IBOutlet UITextField *CustomAmountTextField;
/** 输入自定义金额框 */
@property (weak, nonatomic) IBOutlet UIView *CustomAmountView;
/** tips提示 */
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
/** 确认付款的金额 */
@property (weak, nonatomic) IBOutlet UILabel *payAmountLabel;
/** 确认付款中显示的姓名 */
@property (weak, nonatomic) IBOutlet UILabel *confirmNameLabel;
/** 付款方式 */
@property (weak, nonatomic) IBOutlet UILabel *paymentLabel;
/** 立即付款 */
@property (weak, nonatomic) IBOutlet UIView *gotoPayHUD;
/** 付款信息确认页 */
@property (weak, nonatomic) IBOutlet UIView *confirmView;
/** 确认付款中的金额 */
@property (nonatomic ,strong) NSString * paymentAmount;
/** 支付密码 */
@property (nonatomic ,strong) NSString * password;
/** 支付密码输入页面 */
@property (nonatomic ,strong) DTFPaymentPasswordView * paymentView;
/** 原生导航栏的遮盖 */
@property (nonatomic, strong) UIView * navigationBarHUD;
/** 姓名 */
@property (nonatomic, strong) NSString * name;
/** 银行卡信息 */
@property (nonatomic, strong) NSString * bank;
/** 规则提示 */
@property (nonatomic, strong) NSString * notes;
/** 成功的提示View */
@property (nonatomic, strong) UIView * successView;
/** 失败的提示View */
@property (nonatomic, strong) UIView * errorView;
/** 支付密码错误的提示 */
@property (nonatomic, strong) UIView * passwordIncorrectView;
/** HUD */
@property(nonatomic ,strong) MBProgressHUD * HUD;


@end

@implementation DTFRechargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"大钱包充值";
    
    [self.fiftyButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    [self.fiftyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.fiftyButton setBackgroundColor:[UIColor whiteColor]];
    self.fiftyButton.layer.cornerRadius = 5.0;
    self.fiftyButton.layer.borderWidth = 1.0;
    self.fiftyButton.layer.borderColor = [[UIColor colorWithHex:0xfdb731] CGColor];
    self.fiftyButton.clipsToBounds = YES;
    self.fiftyButton.selected = NO;

    [self.OneHundredButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    [self.OneHundredButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.OneHundredButton setBackgroundColor:[UIColor whiteColor]];
    self.OneHundredButton.layer.cornerRadius = 5.0;
    self.OneHundredButton.layer.borderWidth = 1.0;
    self.OneHundredButton.layer.borderColor = [[UIColor colorWithHex:0xfdb731] CGColor];
    self.OneHundredButton.clipsToBounds = YES;
    self.OneHundredButton.selected = NO;
    
    [self.TwoHundredButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    [self.TwoHundredButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.TwoHundredButton setBackgroundColor:[UIColor whiteColor]];
    self.TwoHundredButton.layer.cornerRadius = 5.0;
    self.TwoHundredButton.layer.borderWidth = 1.0;
    self.TwoHundredButton.layer.borderColor = [[UIColor colorWithHex:0xfdb731] CGColor];
    self.TwoHundredButton.clipsToBounds = YES;
    self.TwoHundredButton.selected = NO;
    
    self.CustomAmountView.layer.cornerRadius = 5.0;
    self.CustomAmountView.layer.borderWidth = 1.0;
    self.CustomAmountView.layer.borderColor = [[UIColor colorWithHex:0xfdb731] CGColor];
    self.CustomAmountView.clipsToBounds = YES;
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToHiddenKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.CustomAmountTextField.delegate = self;
    
    //初始化
    self.gotoPayHUD.hidden = YES;
    self.gotoPayHUD.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.paymentAmount = @"";
    
    
    [self getInitInfo];
    
    //充值记录
    UIBarButtonItem *RightButton = [[UIBarButtonItem alloc] initWithTitle:@"充值记录" style:UIBarButtonItemStylePlain target:self action:@selector(rechargeRecord)];
    RightButton.tintColor =[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = RightButton;
    
    NSString *encodedImageStr = [CoreArchive strForKey:LOGIN_USER_PNG];
    if ([Util IsStringNil:encodedImageStr]) {
        self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
    }else{
        @try {
            NSData *encodeddata = [NSData dataFromBase64String:encodedImageStr];
            UIImage *encodedimage = [UIImage imageWithData:encodeddata];
            self.imageView.image = [Util circleImage:encodedimage withParam:0];
        } @catch (NSException *exception) {
            self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
        }
    }
    
    // token失效 重新登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenInvalid:) name:@"token_invalid" object:nil];

}

#pragma mark - 充值记录
-(void)rechargeRecord{
    
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
    BdH5VC *rechargeRecord = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
    [rechargeRecord setValue:@"/h5/transaction_record.html?" forKey:@"url"];
    [rechargeRecord setValue:@"充值记录" forKey:@"tit"];
    rechargeRecord.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:rechargeRecord animated:YES];
}


-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self hiddenNavigationBarHUD];
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self hiddenNavigationBarHUD];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationBarHUD.hidden=NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


-(void)setPaymentAmount:(NSString *)paymentAmount{
    
    _paymentAmount = paymentAmount;
    self.payAmountLabel.text = paymentAmount;
}



/**
 点击消失弹出的键盘
 */
-(void)tapToHiddenKeyboard{
    
    [self.CustomAmountTextField resignFirstResponder];
}

#pragma mark -- UITextFieldDelegate



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    DMLog(@"%@",string);
    if([string isEqualToString:@""]){
        return YES;
    }
    
    //限制输入框中输入的位数不超过3位
    if(self.CustomAmountTextField.text.length >= 3){
        return NO;
    }else{
        return YES;
    }
    
    
    
//    //字符串的第一位不能输入0,后面中间的可以输入0
//    if([[string substringToIndex:1] isEqualToString:@"0"] && [self.CustomAmountTextField.text isEqualToString:@""]){
//        return NO;
//    }
//
//    //请输入50-500之间的任意整数进行充值~
//    if([string integerValue]>500 || [[self.CustomAmountTextField.text stringByAppendingString:string] integerValue]>500){
//        [MBProgressHUD showError:@"请输入50-500之间的任意整数进行充值~"];
//        return NO;
//    }else{
//        return YES;
//    }
}



-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, self.view.frame.origin.y - 64, self.view.frame.size.width, self.view.frame.size.height);
        //CGRect frame = self.navigationController.navigationBar.frame;
        //self.navigationController.navigationBar.frame = CGRectMake(0, frame.origin.y -64, frame.size.width, frame.size.height);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, self.view.frame.origin.y + 64, self.view.frame.size.width, self.view.frame.size.height);
        //CGRect frame = self.navigationController.navigationBar.frame;
        //self.navigationController.navigationBar.frame = CGRectMake(0, frame.origin.y +64, frame.size.width, frame.size.height);
    }];
}



/**
 五十元按钮点击事件

 @param sender 五十元按钮
 */
- (IBAction)fiftyButtonClick:(UIButton *)sender {
    
    DMLog(@"50元");
    self.fiftyButton.selected = !self.fiftyButton.selected;
    self.OneHundredButton.selected = NO;
    self.TwoHundredButton.selected = NO;
    if(self.fiftyButton.selected){
        self.CustomAmountTextField.text = @"";
        self.fiftyButton.backgroundColor = [UIColor colorWithHex:0xfdb731];
        self.OneHundredButton.backgroundColor = [UIColor whiteColor];
        self.TwoHundredButton.backgroundColor = [UIColor whiteColor];
    }else{
        self.CustomAmountTextField.text = @"";
        self.fiftyButton.backgroundColor = [UIColor whiteColor];
        return ;
    }
    
    self.gotoPayHUD.hidden = NO;
    [self showNavigationBarHUD];
    [self.CustomAmountTextField resignFirstResponder];
    self.paymentAmount = @"50";
    self.payAmountLabel.text = @"50";
    
    //获取初始化信息失败
    if(self.name == nil){
        [self getInitInfo];
    }
    
    //确认付款页面弹出动画
    CGRect beforeFrame = self.confirmView.frame;
    self.confirmView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y + 200, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.confirmView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.confirmView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y - 200, afterFrame.size.width, afterFrame.size.height);
    }];
}


/**
 一百元按钮点击事件

 @param sender 一百元按钮
 */
- (IBAction)oneHundredButtonClick:(UIButton *)sender {
    
    DMLog(@"100元");
    self.OneHundredButton.selected = !self.OneHundredButton.selected;
    self.fiftyButton.selected = NO;
    self.TwoHundredButton.selected = NO;
    if(self.OneHundredButton.selected){
        self.CustomAmountTextField.text = @"";
        self.OneHundredButton.backgroundColor = [UIColor colorWithHex:0xfdb731];
        self.fiftyButton.backgroundColor = [UIColor whiteColor];
        self.TwoHundredButton.backgroundColor = [UIColor whiteColor];
    }else{
        self.CustomAmountTextField.text = @"";
        self.OneHundredButton.backgroundColor = [UIColor whiteColor];
        return ;
    }
    self.gotoPayHUD.hidden = NO;
    [self showNavigationBarHUD];
    [self.CustomAmountTextField resignFirstResponder];
    self.paymentAmount = @"100";
    self.payAmountLabel.text = @"100";
    
    //获取初始化信息失败
    if(self.name == nil){
        [self getInitInfo];
    }
    
    //确认付款页面弹出动画
    CGRect beforeFrame = self.confirmView.frame;
    self.confirmView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y + 200, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.confirmView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.confirmView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y - 200, afterFrame.size.width, afterFrame.size.height);
    }];
}



/**
 两百元按钮点击事件

 @param sender 两百元按钮
 */
- (IBAction)twoHundredButtonClick:(UIButton *)sender {
    
    DMLog(@"200元");
    self.TwoHundredButton.selected = !self.TwoHundredButton.selected;
    self.fiftyButton.selected = NO;
    self.OneHundredButton.selected = NO;
    if(self.TwoHundredButton.selected){
        self.CustomAmountTextField.text = @"";
        self.TwoHundredButton.backgroundColor = [UIColor colorWithHex:0xfdb731];
        self.fiftyButton.backgroundColor = [UIColor whiteColor];
        self.OneHundredButton.backgroundColor = [UIColor whiteColor];
    }else{
        self.CustomAmountTextField.text = @"";
        self.TwoHundredButton.backgroundColor = [UIColor whiteColor];
        return ;
    }
    self.gotoPayHUD.hidden = NO;
    [self showNavigationBarHUD];
    [self.CustomAmountTextField resignFirstResponder];
    self.paymentAmount = @"200";
    self.payAmountLabel.text = @"200";
    
    //获取初始化信息失败
    if(self.name == nil){
        [self getInitInfo];
    }
    
    
    //确认付款页面弹出动画
    CGRect beforeFrame = self.confirmView.frame;
    self.confirmView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y + 200, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.confirmView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.confirmView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y - 200, afterFrame.size.width, afterFrame.size.height);
    }];
}




/**
 立即充值按钮点击事件

 @param sender 立即充值按钮
 */
- (IBAction)rechargeButtonClick:(UIButton *)sender {
    
    DMLog(@"立即充值按钮点击");
    if([self.CustomAmountTextField.text integerValue]<50 || [self.CustomAmountTextField.text integerValue]>500){
        [MBProgressHUD showError:@"请输入50-500之间的任意整数进行充值~"];
        return ;
    }
    self.paymentAmount = self.CustomAmountTextField.text;
    self.gotoPayHUD.hidden = NO;
    [self.CustomAmountTextField resignFirstResponder];
    [self showNavigationBarHUD];
    
    
    //获取初始化信息失败
    if(self.name == nil){
        [self getInitInfo];
    }
    
    
    //确认付款页面弹出动画
    CGRect beforeFrame = self.confirmView.frame;
    self.confirmView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y + 200, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.confirmView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.confirmView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y - 200, afterFrame.size.width, afterFrame.size.height);
    }];
}


/**
 关闭按钮点击事件

 @param sender 关闭按钮
 */
- (IBAction)closeButtonClick:(UIButton *)sender {
    
    self.gotoPayHUD.hidden = YES;
    [self hiddenNavigationBarHUD];
}


/**
 立即付款按钮点击事件

 @param sender 立即付款按钮
 */
- (IBAction)gotoPayButtonClick:(UIButton *)sender {
    
    DMLog(@"立即付款按钮点击事件");
    
    //判断输入的是否为纯数字
    if(![self deptNumInputShouldNumber:self.paymentAmount]){
        [MBProgressHUD showError:@"请输入50-500之间的任意整数进行充值~"];
        return ;
    }
    
    //判断金额是否介于50-500
    if([self.paymentAmount integerValue]<50 || [self.paymentAmount integerValue]>500){
        [MBProgressHUD showError:@"请输入50-500之间的任意整数进行充值~"];
        return ;
    }
    
    
    
    //支付密码输入页面
    DTFPaymentPasswordView *paymentPasswordView = [[NSBundle mainBundle] loadNibNamed:@"DTFPaymentPasswordView" owner:nil options:nil].firstObject;
    paymentPasswordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.paymentView = paymentPasswordView;
    self.paymentView.nav = self.navigationController;
    __weak typeof(self)weakSelf = self;
    self.paymentView.completeBlock = ^(NSString *password) {
        
        weakSelf.password = password;
        [weakSelf gotoPay];
        [weakSelf closeButtonClick:nil];
        
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

#pragma mark - 覆盖原生导航条

-(void)showNavigationBarHUD{
    
    __block UIView * blockView = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        blockView = [[UIApplication sharedApplication].windows lastObject];
        
        UIView *navigationBarHUD = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        self.navigationBarHUD = navigationBarHUD;
        navigationBarHUD.backgroundColor= [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        
        [self.navigationController.view addSubview:self.navigationBarHUD];
    });
}


-(void)hiddenNavigationBarHUD{
    
    self.navigationBarHUD.hidden=YES;
}


#pragma mark - 获取初始化页面信息

-(void)getInitInfo{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_INIT_RECHARGE];

    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
     
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"获取初始化页面信息-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            self.name = dictData[@"data"][@"name"];
            self.bank = dictData[@"data"][@"bank"];
            self.notes = dictData[@"data"][@"notes"];
            self.nameLabel.text = self.name;
            self.tipsLabel.text = self.notes;
            self.confirmNameLabel.text = self.name;
            self.paymentLabel.text = self.bank;

        }else{//本人认证资格
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
    } failure:^(NSError *error) {
        
        DMLog(@"请求失败--%@",error);
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

#pragma mark - 立即付款充值

/** 立即付款:大钱包充值 */
-(void)gotoPay{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    //对参数进行AES加密 key:Yi17wu_EnPun_k88 iv:Wu17yi_EnPuv_i66
    
    NSString * accessToken = aesEncryptString([CoreArchive strForKey:LOGIN_ACCESS_TOKEN], AESEncryptKey);
    NSString * deviceType = aesEncryptString(@"2", AESEncryptKey);
    NSString * appVersion = aesEncryptString([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], AESEncryptKey);
    NSString * password = aesEncryptString(self.password, AESEncryptKey);
    NSString * amount = aesEncryptString(self.paymentAmount, AESEncryptKey);
    
    
    param[@"access_token"] = accessToken;
    param[@"device_type"] = deviceType;
    param[@"app_version"] = appVersion;
    param[@"password"] = password;
    param[@"amount"] = amount;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_RECHARGE];
    
    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        //对AES加密结果进行解密
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSString * dataBack = dictData[@"dataBack"];
        NSString * decodeString = aesDecryptString(dataBack, AESEncryptKey);
        dictData = [self dictionaryWithJsonString:decodeString];
        
        DMLog(@"dictData==%@",dictData);


        if([dictData[@"resultCode"] integerValue] == 200){//支付成功
            [self showSuccessView];
        }else if([dictData[@"resultCode"] integerValue] == 201){//业务错误
            [self showErrorViewWithTips:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }else if([dictData[@"resultCode"] integerValue] == 203){//支付密码错误
            [self showPasswordIncorrectWithTips:[NSString stringWithFormat:@"%@",dictData[@"message"]] andButtonText:@"重新输入"];
        }else if([dictData[@"resultCode"] integerValue] == 204){//密码错误达到上限
            [self showPasswordIncorrectWithTips:[NSString stringWithFormat:@"%@",dictData[@"message"]] andButtonText:@"关闭"];
        }else{//其他错误
            [self showErrorViewWithTips:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {//网络不可用
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {//支付超时
            [self showTimeOver];
        }
    }];
}


#pragma mark - 显示成功的提示

-(void)showSuccessView{
    
    
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.15, SCREEN_HEIGHT *0.2422, SCREEN_WIDTH * 0.7, SCREEN_HEIGHT *0.2375);
    UIView * successView = [[UIView alloc]initWithFrame:frame];
    self.successView = successView;
    successView.backgroundColor = [UIColor whiteColor];
    successView.clipsToBounds = YES;
    successView.layer.cornerRadius = 7.0;
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.215, frame.size.width * 0.198, frame.size.width * 0.198);//frame.size.width *0.198
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:@"icon_success"];
    [self.successView addSubview:imageView];
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,frame.size.height * 0.65, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"支付成功！";
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [self.successView addSubview:tipsLabel];
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:successView];
    [self.navigationController.view addSubview:hudView];
    
    self.successView = hudView;
    
    //3.0秒后消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.successView.hidden = YES;
    });
}


#pragma mark - 显示失败的提示

-(void)showErrorViewWithTips:(NSString *)tips{
    
    
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.1, SCREEN_HEIGHT *0.287, SCREEN_WIDTH * 0.8, SCREEN_HEIGHT *0.2870);
    UIView * errorView = [[UIView alloc]initWithFrame:frame];
    self.errorView = errorView;
    errorView.backgroundColor = [UIColor whiteColor];
    errorView.clipsToBounds = YES;
    errorView.layer.cornerRadius = 7.0;
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.15, frame.size.width * 0.198, frame.size.width * 0.198);//frame.size.width *0.198
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:@"icon_fail"];
    [self.errorView addSubview:imageView];
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,frame.size.height * 0.50, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"支付失败！";
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [self.errorView addSubview:tipsLabel];
    
    
    //DetailsLabel
    CGRect detailsFrame = CGRectMake(frame.size.width * 0.12,frame.size.height * 0.645, frame.size.width *0.76, frame.size.height * 0.3);
    UILabel *detailsLabel = [[UILabel alloc]initWithFrame:detailsFrame];
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.text = tips;
    detailsLabel.numberOfLines = 0;
    detailsLabel.textColor = [UIColor colorWithHex:0xff0000];
    detailsLabel.font = [UIFont systemFontOfSize:15.0];
    [self.errorView addSubview:detailsLabel];
    
    
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:errorView];
    [self.navigationController.view addSubview:hudView];
    
    self.errorView = hudView;
    
    //弹出显示失败信息的动画
    CGRect beforeFrame = errorView.frame;
    errorView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y -400, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = errorView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        
        errorView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y + 400, afterFrame.size.width, afterFrame.size.height);
        
    } completion:^(BOOL finished) {
        
        //3.0秒后消失
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                
                errorView.frame = CGRectMake(errorView.origin.x, errorView.origin.y + 600, errorView.size.width, errorView.size.height);
                
            } completion:^(BOOL finished) {
                
                self.errorView.hidden = YES;
            }];
        });
    }];
}


#pragma mark - 显示支付密码错误的提示 - 错误以及达到上限
-(void)showPasswordIncorrectWithTips:(NSString *)tips andButtonText:(NSString *)buttonText{
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.08, SCREEN_HEIGHT *0.2422, SCREEN_WIDTH * 0.84, SCREEN_HEIGHT *0.3296);
    UIView * passwordIncorrectView = [[UIView alloc]initWithFrame:frame];
    self.passwordIncorrectView = passwordIncorrectView;
    passwordIncorrectView.backgroundColor = [UIColor whiteColor];
    passwordIncorrectView.clipsToBounds = YES;
    passwordIncorrectView.layer.cornerRadius = 15.0;
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.08, frame.size.width * 0.198, frame.size.width * 0.198);//frame.size.width *0.198
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:@"icon_fail"];
    [self.passwordIncorrectView addSubview:imageView];
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,frame.size.height * 0.36, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"支付失败！";
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [self.passwordIncorrectView addSubview:tipsLabel];
    
    
    //DetailsLabel--错误详情
    CGRect detailsFrame = CGRectMake(frame.size.width * 0.12,frame.size.height * 0.455, frame.size.width *0.76, frame.size.height * 0.3);
    UILabel *detailsLabel = [[UILabel alloc]initWithFrame:detailsFrame];
    detailsLabel.text = tips;
    detailsLabel.numberOfLines = 0;
    detailsLabel.textColor = [UIColor colorWithHex:0xff0000];
    detailsLabel.font = [UIFont systemFontOfSize:15.0];
    [self.passwordIncorrectView addSubview:detailsLabel];
    
    
    //分割线
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height * 0.80, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    [self.passwordIncorrectView addSubview:seperatorView];
    
    //重新输入按钮
    UIButton * reInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reInputButton.frame = CGRectMake(0, frame.size.height * 0.80 + 1, frame.size.width, frame.size.height *0.20);
    [reInputButton setTitle:buttonText forState:UIControlStateNormal];
    [reInputButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    [reInputButton addTarget:self action:@selector(reInputPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordIncorrectView addSubview:reInputButton];
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:passwordIncorrectView];
    [self.navigationController.view addSubview:hudView];
    
    self.passwordIncorrectView = hudView;
}


#pragma mark - 显示超时提示
-(void)showTimeOver{
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.08, SCREEN_HEIGHT *0.2422, SCREEN_WIDTH * 0.84, SCREEN_HEIGHT *0.3096);
    UIView * passwordIncorrectView = [[UIView alloc]initWithFrame:frame];
    self.passwordIncorrectView = passwordIncorrectView;
    passwordIncorrectView.backgroundColor = [UIColor whiteColor];
    passwordIncorrectView.clipsToBounds = YES;
    passwordIncorrectView.layer.cornerRadius = 15.0;

    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(frame.size.width *0.05,frame.size.height * 0.1, frame.size.width *0.9, frame.size.height * 0.6);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.numberOfLines = 0;
    tipsLabel.textColor = [UIColor colorWithHex:0x333333];
    tipsLabel.text = @"充值交易超时，是否充值成功，以市民卡银行账户余额变动为准，请最迟在下一工作日查询充值记录，给您带来不便，深表歉意~";
    tipsLabel.font = [UIFont systemFontOfSize:16.0];
    [self.passwordIncorrectView addSubview:tipsLabel];
    
    
    //分割线
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height * 0.74, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    [self.passwordIncorrectView addSubview:seperatorView];
    
    //我知道了按钮
    UIButton * knewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knewButton.frame = CGRectMake(0, frame.size.height * 0.74 + 1, frame.size.width, frame.size.height *0.27);
    [knewButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [knewButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    [knewButton addTarget:self action:@selector(iKnew) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordIncorrectView addSubview:knewButton];
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:passwordIncorrectView];
    [self.navigationController.view addSubview:hudView];
    
    self.passwordIncorrectView = hudView;
}



#pragma mark - 重新输入支付密码
-(void)reInputPassword:(UIButton *)button{
    
    if([button.titleLabel.text isEqualToString:@"重新输入"]){
        DMLog(@"重新输入支付密码");
        self.passwordIncorrectView.hidden = YES;
        self.gotoPayHUD.hidden = NO;
        [self showNavigationBarHUD];
        [self gotoPayButtonClick:nil];
        [self.CustomAmountTextField resignFirstResponder];
    }else{//关闭
        self.passwordIncorrectView.hidden = YES;
    }
}


#pragma mark - 我知道了按钮点击事件

-(void)iKnew{
    self.passwordIncorrectView.hidden = YES;
}

/**
 *  支付中加载动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"支付中";
}

- (void)dealloc{
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 字符串转字典
//json格式字符串转字典：

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



/**
 判断字符串是否为纯数字

 @param str 字符串
 @return 是否为纯数字
 */
- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

-(void)tokenInvalid:(NSNotification *)notification{
    
    DMLog(@"大钱包充值-收到下线通知");
    self.paymentView.hidden = YES;
    self.passwordIncorrectView.hidden = YES;
}


@end
