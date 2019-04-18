//
//  YWLoginVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWLoginVC.h"
#import "YWPswLoginView.h"
#import "YWSlLoginView.h"
#import "UserBean.h"
#import "JPUSHService.h"
#import "ModifyCardView.h"
#import "ModifySMCardVC.h"
#import "ModifyHXCardVC.h"
#import "LossAlertView.h"
#import "SettingWebVC.h"
#import "DTFAuthFailVC.h"
#import "DTFAuthCannotFailVC.h"
#import "YWRegistVC.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"

#define REGIST_ZHIMA_INIT           @"zhima/zhimaCertificationInitialize/new" //登录-实人认证-初始化
#define REGIST_ZHIMA_RESULT         @"zhima/zhimaAuthResult/login"  //查询芝麻认证结果


@interface YWLoginVC ()<UIScrollViewDelegate,UITextFieldDelegate>

/** 密码登录View */
@property (nonatomic,strong) YWPswLoginView * pswLoginView;
/** 刷脸登录View */
@property (nonatomic,strong) YWSlLoginView * slLoginView;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstains;


@end

@implementation YWLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    if (kIsiPhoneX) {
        self.topConstains.constant +=30;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


-(void)setupUI{
    
    self.title = @"登录";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(regist)]; //为导航栏添加右侧按钮
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    //初始化默认选中密码登录
    self.isPswLogin = YES;
    self.pswLoginButton.selected = YES;
    self.slLoginButton.selected = NO;
    
    self.pswOrslView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 240);
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.pswOrslView.frame];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.pswOrslView.frame.size.width*2.0, self.pswOrslView.frame.size.height);
    [self.pswOrslView addSubview:self.scrollView];
    
    
    //密码登录
    self.pswLoginView = [YWPswLoginView pswLoginView];
    self.pswLoginView.frame = self.pswOrslView.frame;
    self.pswLoginView.identifyView.layer.borderWidth = 1.0;
    self.pswLoginView.identifyView.layer.borderColor = [UIColor colorWithHex:0xeeeeee].CGColor;
    self.pswLoginView.identifyView.layer.cornerRadius = 5.0;
    self.pswLoginView.identifyView.clipsToBounds = YES;
    
    self.pswLoginView.pswView.layer.borderWidth = 1.0;
    self.pswLoginView.pswView.layer.borderColor = [UIColor colorWithHex:0xeeeeee].CGColor;
    self.pswLoginView.pswView.layer.cornerRadius = 5.0;
    self.pswLoginView.pswView.clipsToBounds = YES;
    
    
    NSString * shbzh = [[CoreArchive strForKey:CACHE_SHBZH] substringToIndex:12];
    if(shbzh !=nil){
        shbzh = [NSString stringWithFormat:@"%@******",shbzh];
    }else{
        shbzh = @"";
    }
    
    
    self.pswLoginView.identifyTextField.text = shbzh;
    self.pswLoginView.identifyTextField.delegate = self;
    
    self.pswLoginView.navVC = self.navigationController;
    [self.scrollView addSubview:self.pswLoginView];
    
    
    
    
    //刷脸登录
    self.slLoginView = [YWSlLoginView slLoginView];
    self.slLoginView.frame = CGRectMake(self.pswOrslView.frame.size.width, 0, self.pswOrslView.frame.size.width, self.pswOrslView.frame.size.height);
    self.slLoginView.identifyView.layer.borderWidth = 1.0;
    self.slLoginView.identifyView.layer.borderColor = [UIColor colorWithHex:0xeeeeee].CGColor;
    self.slLoginView.identifyView.layer.cornerRadius = 5.0;
    self.slLoginView.identifyView.clipsToBounds = YES;
    
    self.slLoginView.identifyTextField.text  = shbzh;
    self.slLoginView.identifyTextField.delegate = self;
    
    
    [self.scrollView addSubview:self.slLoginView];
    
    
    
    //登录按钮
    self.loginButton.clipsToBounds = YES;
    self.loginButton.layer.cornerRadius = 5.0;
    
    //注册通知
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(registSuccess) name:@"regist_setPayPassword_finish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zhimaLogin:) name:@"zhimaLogin" object:@"1"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)tapView{
    
    [self.pswLoginView.identifyTextField resignFirstResponder];
    [self.pswLoginView.pswTextField resignFirstResponder];
    [self.slLoginView.identifyTextField resignFirstResponder];
    
}


-(void)back{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)regist{
    
    UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
    YWRegistVC * registVC = [UB instantiateViewControllerWithIdentifier:@"YWRegistVC"];
    [self.navigationController pushViewController:registVC animated:YES];
    
}


/** 注册成功 */
-(void)registSuccess{
    
    self.pswLoginView.identifyTextField.text = [CoreArchive strForKey:CACHE_SHBZH];
    self.slLoginView.identifyTextField.text = [CoreArchive strForKey:CACHE_SHBZH];
    
    UIButton * registSuccessButton = [UIButton buttonWithType:UIButtonTypeSystem];
    registSuccessButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    registSuccessButton.tintColor = [UIColor whiteColor];
    registSuccessButton.layer.cornerRadius = 5.0;
    registSuccessButton.clipsToBounds = YES;
    CGFloat buttonX = [UIScreen mainScreen].bounds.size.width * 0.5 - 90;
    CGFloat buttonY = 0.0;
    if([UIScreen mainScreen].bounds.size.width == 320){//5s
        buttonY = [UIScreen mainScreen].bounds.size.height * 0.5 + 10;
    }else if ([UIScreen mainScreen].bounds.size.width == 375){//6、7、8
        buttonY = [UIScreen mainScreen].bounds.size.height * 0.5 - 80;
    }else if ([UIScreen mainScreen].bounds.size.width == 414){
        buttonY = [UIScreen mainScreen].bounds.size.height * 0.5 - 80;
    }else{
        buttonY = [UIScreen mainScreen].bounds.size.height * 0.5 - 80;
    }
    registSuccessButton.frame = CGRectMake(buttonX, buttonY, 180, 60);
    registSuccessButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [registSuccessButton setImage:[UIImage imageNamed:@"icon_success"] forState:UIControlStateNormal];
    [registSuccessButton setTitle:@"注册成功!" forState:UIControlStateNormal];
    registSuccessButton.imageView.bounds = CGRectMake(0, 0, 50, 50);
    [registSuccessButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [registSuccessButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self.view addSubview:registSuccessButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [registSuccessButton removeFromSuperview];
    });
    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"regist_setPayPassword_finish" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"zhimaLogin" object:nil];
}

#pragma mark - showLoadingUI
/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
    self.HUD.hidden = NO;
}


#pragma mark - 按钮点击事件

/**
 密码登录选择按钮点击事件

 @param sender 密码登录按钮
 */
- (IBAction)pswLoginButtonClick:(UIButton *)sender {
    
    DMLog(@"密码登录选中");
    self.isPswLogin = YES;
    self.pswLoginButton.selected = YES;
    self.slLoginButton.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.indicaterLeadingConstraint.constant = 0;
    }];
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
}


/**
 刷脸登录选择按钮点击事件
 
 @param sender 刷脸登录按钮
 */
- (IBAction)slLoginButtonClick:(UIButton *)sender {
    
    DMLog(@"刷脸登录选中");
    self.isPswLogin = NO;
    self.pswLoginButton.selected = NO;
    self.slLoginButton.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.indicaterLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width*0.5;
    }];
    
    self.scrollView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
    [self.loginButton setTitle:@"刷脸登录" forState:UIControlStateNormal];
}

/**
 登录按钮点击事件
 
 @param sender 登录按钮
 */
- (IBAction)loginButtonClick:(UIButton *)sender {
    
    
    if(self.isPswLogin){
        
        DMLog(@"密码登录");
        if(self.pswLoginView.identifyTextField.text.length ==0){
            [MBProgressHUD showError:@"请输入身份证号"];
            return;
        }
        if(self.pswLoginView.pswTextField.text.length ==0){
            [MBProgressHUD showError:@"请输入登录密码"];
            return;
        }
        
        [self pswLogin];
        
    }else{
        DMLog(@"刷脸登录");
        if(self.slLoginView.identifyTextField.text.length ==0){
            [MBProgressHUD showError:@"请输入身份证号"];
            return;
        }
        [self shualianLogin];
    }
    
    [self.pswLoginView.identifyTextField resignFirstResponder];
    [self.pswLoginView.pswTextField resignFirstResponder];
    [self.slLoginView.identifyTextField resignFirstResponder];
    
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    if(self.scrollView.contentOffset.x>0){//刷脸登录
        
        self.isPswLogin = NO;
        self.slLoginButton.selected = YES;
        self.pswLoginButton.selected = NO;
        self.indicaterLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width*0.5;
        [self.loginButton setTitle:@"刷脸登录" forState:UIControlStateNormal];
        
        
    }else{//密码登录
        
        self.isPswLogin = YES;
        self.slLoginButton.selected = NO;
        self.pswLoginButton.selected = YES;
        self.indicaterLeadingConstraint.constant = 0;
        self.loginButton.titleLabel.text = @"登录";
        
    }
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    
    [self.pswLoginView.identifyTextField resignFirstResponder];
    [self.pswLoginView.pswTextField resignFirstResponder];
    [self.slLoginView.identifyTextField resignFirstResponder];
    
}


#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([Util IsStringNil:string])
    {
        if([textField.text containsString:@"*"]){
            textField.text = @"";
        }
        return YES;
    }
    
    if(textField ==  self.pswLoginView.identifyTextField){
        
        if(self.pswLoginView.identifyTextField.text.length >= 18){
            return NO;
        }else{
            
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
            
            
            
            return YES;
        }
    }else if (textField ==  self.slLoginView.identifyTextField){
        
        if(self.slLoginView.identifyTextField.text.length >= 18){
            return NO;
        }else{
            
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
            
            return YES;
        }
    }else if (textField ==  self.pswLoginView.pswTextField){
        
        if(self.pswLoginView.pswTextField.text.length >= 18){
            return NO;
        }else{
            return YES;
        }
    }
    
    
    
    
    
    
    return YES;
}



#pragma mark -  密码登录

/** 密码登录 */
-(void)pswLogin{
    
    if([CoreArchive intForKey:loginErrorCount]>=5){//登录错误过于频繁
  
        NSString * lastErrorTimeString = [CoreArchive strForKey:loginErrorTime] ;
        NSUInteger lastErrorTime = [lastErrorTimeString integerValue];
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString * nowTimeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
        NSUInteger nowTime = [nowTimeString integerValue];
        
        if((nowTime -lastErrorTime)<600){
            [MBProgressHUD showError:@"登录错误过于频繁，请稍后重试"];
            return;
        }
    }
    
    
    
    
    NSString * aesPswString =aesEncryptString([Util MD5:self.pswLoginView.pswTextField.text], AESEncryptKey);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString * shbzh = @"";
    if([self.pswLoginView.identifyTextField.text containsString:@"*"]){
        shbzh = [CoreArchive strForKey:CACHE_SHBZH];
    }else{
        shbzh = self.pswLoginView.identifyTextField.text;
    }
    NSLog(@"shbzh=====%@",shbzh);
    NSString * aesShbzhString =aesEncryptString(shbzh, AESEncryptKey);
    NSLog(@"aesShbzhString=====%@",aesShbzhString);
    
    
    param[@"shbzh"] = aesShbzhString;
    param[@"password"] = aesPswString;
    param[@"imei"] = [Util getuuid];
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;

    DMLog(@"param=%@",param);
    
    self.shbzh = self.pswLoginView.identifyTextField.text;
    
    NSString *url = [NSString stringWithFormat:@"%@/userServer/loginSystem/password/New/aes",HOST_TEST];
    DMLog(@"url=%@",url);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden= YES;
        
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"义乌2.3登录=resultDict==%@",resultDict);
        
        
        if([resultDict[@"resultCode"] integerValue]==200){
            
            [CoreArchive setInt:0 key:loginErrorCount];
            
            //解密
            NSString * dataBackString = aesDecryptString(resultDict[@"data"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];
            
            
            if(![self.pswLoginView.identifyTextField.text containsString:@"*"]){
                [CoreArchive setStr:self.pswLoginView.identifyTextField.text key:CACHE_SHBZH];
            }
            
            
            UserBean *bean = [UserBean mj_objectWithKeyValues:resultDict];
       
 
            [CoreArchive setBool:YES key:LOGIN_STUTAS];
            [CoreArchive setStr:bean.id key:LOGIN_ID];
            [CoreArchive setStr:bean.name key:LOGIN_NAME];
            [CoreArchive setStr:bean.password key:LOGIN_USER_PSD];
            
            [CoreArchive setStr:bean.cardType key:LOGIN_CARD_TYPE];
            [CoreArchive setStr:bean.cardno key:LOGIN_CARD_NUM];
            [CoreArchive setStr:bean.shbzh key:LOGIN_SHBZH];
            [CoreArchive setStr:bean.bank key:LOGIN_BANK];
            
            [CoreArchive setStr:bean.bankCard key:LOGIN_BANK_CARD];
            [CoreArchive setStr:bean.isHaveCard key:LOGIN_ISHaveCard];
            [CoreArchive setStr:bean.userPng key:LOGIN_USER_PNG];
            [CoreArchive setStr:bean.cardMobile key:LOGIN_CARD_MOBILE];
            [CoreArchive setStr:bean.bankMobile key:LOGIN_BANK_MOBILE];
            
            [CoreArchive setStr:bean.appMobile key:LOGIN_APP_MOBILE];
            [CoreArchive setStr:bean.cardStatus key:LOGIN_CARD_STATUS];
            [CoreArchive setStr:bean.dzyx key:LOGIN_DZYX];
            [CoreArchive setStr:bean.yjdz key:LOGIN_YJDZ];
            
            [CoreArchive setStr:bean.updateTime key:LOGIN_UPDATE_TIME];
            [CoreArchive setStr:bean.createTime key:LOGIN_CREATE_TIME];
            [CoreArchive setStr:bean.access_token key:LOGIN_ACCESS_TOKEN];
            
            [CoreArchive setStr:bean.citCardNum key:LOGIN_CIT_CARDNUM];
            [CoreArchive setStr:bean.bankCode key:LOGIN_BANK_CODE];
            [CoreArchive setStr:bean.ydzf_status key:LOGIN_YDZF_STATUS];
            [CoreArchive setStr:bean.srrz_status key:LOGIN_SRRZ_STATUS];
            [CoreArchive setStr:bean.bankzf_status key:LOGIN_BANKZF_STATUS];
            
            [CoreArchive setStr:bean.birthDate key:LOGIN_BIRTHDATE];
            [CoreArchive setStr:bean.gender key:LOGIN_GENDER];
            [CoreArchive setStr:bean.push_alias key:JPUSH_ALIAS]; // 保存极光别名
            
            [CoreArchive setStr:bean.setPassword key:LOGIN_SET_PAY_PSW];
            
            
            //是否设置过支付密码
            if([bean.setPassword integerValue]==0){//未设置过支付密码
                
                DMLog(@"未设置支付密码");
                [YWManager sharedManager].isSettedPayPassword = NO;
                
            }else if([bean.setPassword integerValue]==1){//设置过支付密码
                
                DMLog(@"设置过支付密码");
                [YWManager sharedManager].isSettedPayPassword = YES;
                
            }else{//获取是否设置过支付密码失败
                [MBProgressHUD showError:@"支付密码是否设置结果查询失败"];
            }
            
            //是否有卡
            if([bean.isHaveCard isEqualToString:@"1"]){//you卡
                
                DMLog(@"有卡");
                [YWManager sharedManager].isHasCard = YES;
                
            }else{//无卡
                DMLog(@"无卡");
                [YWManager sharedManager].isHasCard = NO;
               
            }
            
            
            //是否实人认证
            if([bean.srrz_status isEqualToString:@"1"]){//实人认证通过
                
                DMLog(@"实人认证通过");
                [YWManager sharedManager].isAuthentication = YES;
            }else{//实人认证未通过
                
                DMLog(@"实人认证未通过");
                [YWManager sharedManager].isAuthentication = NO;
            }
            
            
            
            
            
            //删除极光推送的别名
            
            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
                //DMLog(@"iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
                
                //设置个推的别名Alias--设置别名之前要清楚别名
                [JPUSHService setAlias:bean.push_alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    
                    //DMLog(@"设置别名--iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
                    
                } seq:0];
            } seq:0];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"isLogin" object:nil userInfo:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
                
          
        }else{
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
            
            [CoreArchive setStr:timeString key:loginErrorTime];
            NSInteger  errorCount = [CoreArchive intForKey:loginErrorCount];
            errorCount = errorCount + 1;
            [CoreArchive setInt:errorCount key:loginErrorCount];
            NSLog(@"登录错误时间==%@",timeString);
            NSLog(@"登录错误次数==%ld",errorCount);
            
            resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            [MBProgressHUD showError:resultDict[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        self.HUD.hidden = YES;
    }];
}

#pragma mark - 卡注销状态弹窗
-(void)showModifyCardView:(NSString *)msg andCard_Type:(NSString*)card_type andAccess_Token:(NSString*)access_token{
    
    LossAlertView *lll=[LossAlertView alterViewWithContent:msg cancel:@"取消" sure:@"修改" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
        
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"修改");
        if ([card_type isEqualToString:@"1"]) {
            ModifySMCardVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModifySMCardVC"];
            [VC setValue:access_token forKey:@"access_token"];
            [self.navigationController pushViewController:VC animated:YES];
        }else{
            ModifyHXCardVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModifyHXCardVC"];
            [VC setValue:access_token forKey:@"access_token"];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];
    [self.view addSubview:lll];
}

#pragma mark -  刷脸登录

-(void)shualianLogin{
    [self.view endEditing:YES];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString * shbzh = @"";
    if([self.slLoginView.identifyTextField.text containsString:@"*"]){
        shbzh = [CoreArchive strForKey:CACHE_SHBZH];
    }else{
        shbzh = self.slLoginView.identifyTextField.text;
    }
    param[@"shbzh"] = shbzh;
    param[@"app_version"] = version;
    param[@"device_type"] = @"2";
    param[@"business_type"] = @"24";


    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,REGIST_ZHIMA_INIT];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    [self showLoadingUI];

    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;

        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"义乌2.3注册=resultDict==%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){

            self.biz_no = dictData[@"data"][@"bizNo"];
            self.transaction_id = dictData[@"data"][@"transactionId"];
            [self doVerify:dictData[@"data"][@"url"]];

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

- (void)doVerify:(NSString *)url {
    
    NSString *alipayUrl = [NSString stringWithFormat:@"alipays://platformapi/startapp?appId=20000067&url=%@", [self URLEncodedStringWithUrl:url]];
    if ([self canOpenAlipay]) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >=10.0) {
            // 针对 10.0 以上的iOS系统进行处理
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl] options:@{} completionHandler:nil];
        } else {
            // 针对 10.0 以下的iOS系统进行处理
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl]];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否下载并安装支付宝完成认证?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        [alertView show];
    }
}

-(NSString *)URLEncodedStringWithUrl:(NSString *)url {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef) @"!*'();:@&=+$,%#[]|",kCFStringEncodingUTF8));
    return encodedString;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *appstoreUrl = @"itms-apps://itunes.apple.com/app/id333206289";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appstoreUrl] options:@{} completionHandler:nil];
    }
}

- (BOOL)canOpenAlipay {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipays://"]];
}

#pragma mark  - 芝麻认证完成 - 回调到本APP - 接收到APP的通知
-(void)zhimaLogin:(NSNotification *)notice{
    
    DMLog(@"收到芝麻认证回调的通知 - 实人认证 -- %@",notice);
    
    
    
    if([notice.userInfo[@"passed"] boolValue]){
        
        DMLog(@"实人认证成功");
        
    }else{
        DMLog(@"实人认证失败");
    }
    //认证完成后回调服务端
    [self zhimaAuthFinished];
}

#pragma mark - 实人认证完成后的回调服务端
-(void)zhimaAuthFinished{
    
    NSString * shbzh = @"";
    if([self.slLoginView.identifyTextField.text containsString:@"*"]){
        shbzh = [CoreArchive strForKey:CACHE_SHBZH];
    }else{
        shbzh = self.slLoginView.identifyTextField.text;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,REGIST_ZHIMA_RESULT];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"name"] = @"";
    param[@"shbzh"] = shbzh;
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"biz_no"] = self.biz_no;
    param[@"business_type"] = @"24";
    param[@"serial_number"] = @"";//生存认证流水号
    param[@"device_type"] = @"2";//生存认证
    param[@"other_id"] = @"";
    
    
    
    self.shbzh = shbzh;//self.slLoginView.identifyTextField.text;
    
    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);
    
    if(self.biz_no == nil){
        DMLog(@"拦截到biz_no为空！！！！！");
        return;//为了解决收到两次通知的问题
    }
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"登录刷脸完成后的回调服务端--返回结果---%@",dictData);
        
        if([dictData[@"resultCode"] integerValue] == 200){
            DMLog(@"回调服务端查询--登录刷脸成功");
            self.access_token = dictData[@"data"][@"access_token"];
            [self slLogin];
            
            
        }else if([dictData[@"resultCode"] integerValue] == 102){ //认证失败
            
            if(dictData[@"data"] == nil){
                [MBProgressHUD showError:dictData[@"message"]];
                return ;
            }
            
            if(dictData[@"data"][@"srrzCheckFlag"]==nil){
                [MBProgressHUD showError:dictData[@"message"]];
                return ;
            }
            
            if([dictData[@"data"][@"srrzCheckFlag"] integerValue] == 1){//srrzCheckFlag ：实人认证开关状态:开启
                
                if([dictData[@"data"][@"lastSrrzCount"] integerValue] > 0){
                    
                    DTFAuthFailVC *vc = [[DTFAuthFailVC alloc]init];
                    vc.lastSrrzCount =  [dictData[@"data"][@"lastSrrzCount"] integerValue];//设置剩余实人认证的次数
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
                    
                    DTFAuthCannotFailVC *vc = [[DTFAuthCannotFailVC alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{//srrzCheckFlag ：实人认证开关状态:关闭
                [MBProgressHUD showError:dictData[@"message"]];
            }
            DMLog(@"登录刷脸服务端返回的失败原因--%@",dictData[@"message"]);
        }else{
            
            [MBProgressHUD showError:dictData[@"message"]];
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
 刷脸登录
 */
-(void)slLogin{
    
    NSString * shbzhAES = aesEncryptString(self.shbzh, AESEncryptKey);
    
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        param[@"shbzh"] = shbzhAES;
        param[@"access_token"] = self.access_token;
        param[@"imei"] = [Util getuuid];
        param[@"device_type"] = @"2";
        param[@"app_version"] = version;
    
        NSString *url = [NSString stringWithFormat:@"%@/userServer/loginSystem/face/aes",HOST_TEST];
        [HttpHelper post:url params:param success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            
    
            DMLog(@"义乌2.3登录=resultDict==%@",resultDict);
            
            
            if([resultDict[@"resultCode"] integerValue]==200){
                
                NSString * dataBackString = aesDecryptString(resultDict[@"data"], AESEncryptKey);
                resultDict = [NSString db_dictionaryWithJsonString:dataBackString];
                
                if(![self.slLoginView.identifyTextField.text containsString:@"*"]){
                    [CoreArchive setStr:self.slLoginView.identifyTextField.text key:CACHE_SHBZH];
                }
                
                UserBean *bean = [UserBean mj_objectWithKeyValues:resultDict];
                
                
                [CoreArchive setBool:YES key:LOGIN_STUTAS];
                [CoreArchive setStr:bean.id key:LOGIN_ID];
                [CoreArchive setStr:bean.name key:LOGIN_NAME];
                [CoreArchive setStr:bean.password key:LOGIN_USER_PSD];
                
                [CoreArchive setStr:bean.cardType key:LOGIN_CARD_TYPE];
                [CoreArchive setStr:bean.cardno key:LOGIN_CARD_NUM];
                [CoreArchive setStr:bean.shbzh key:LOGIN_SHBZH];
                [CoreArchive setStr:bean.bank key:LOGIN_BANK];
                
                [CoreArchive setStr:bean.bankCard key:LOGIN_BANK_CARD];
                [CoreArchive setStr:bean.isHaveCard key:LOGIN_ISHaveCard];
                [CoreArchive setStr:bean.userPng key:LOGIN_USER_PNG];
                [CoreArchive setStr:bean.cardMobile key:LOGIN_CARD_MOBILE];
                [CoreArchive setStr:bean.bankMobile key:LOGIN_BANK_MOBILE];
                
                [CoreArchive setStr:bean.appMobile key:LOGIN_APP_MOBILE];
                [CoreArchive setStr:bean.cardStatus key:LOGIN_CARD_STATUS];
                [CoreArchive setStr:bean.dzyx key:LOGIN_DZYX];
                [CoreArchive setStr:bean.yjdz key:LOGIN_YJDZ];
                
                [CoreArchive setStr:bean.updateTime key:LOGIN_UPDATE_TIME];
                [CoreArchive setStr:bean.createTime key:LOGIN_CREATE_TIME];
                [CoreArchive setStr:bean.access_token key:LOGIN_ACCESS_TOKEN];
                
                [CoreArchive setStr:bean.citCardNum key:LOGIN_CIT_CARDNUM];
                [CoreArchive setStr:bean.bankCode key:LOGIN_BANK_CODE];
                [CoreArchive setStr:bean.ydzf_status key:LOGIN_YDZF_STATUS];
                [CoreArchive setStr:bean.srrz_status key:LOGIN_SRRZ_STATUS];
                [CoreArchive setStr:bean.bankzf_status key:LOGIN_BANKZF_STATUS];
                
                [CoreArchive setStr:bean.birthDate key:LOGIN_BIRTHDATE];
                [CoreArchive setStr:bean.gender key:LOGIN_GENDER];
                [CoreArchive setStr:bean.push_alias key:JPUSH_ALIAS]; // 保存极光别名
                
                [CoreArchive setStr:bean.setPassword key:LOGIN_SET_PAY_PSW];
                
                
                //是否设置过支付密码
                if([bean.setPassword integerValue]==0){//未设置过支付密码
                    
                    DMLog(@"未设置支付密码");
                    [YWManager sharedManager].isSettedPayPassword = NO;
                    
                }else if([bean.setPassword integerValue]==1){//设置过支付密码
                    
                    DMLog(@"设置过支付密码");
                    [YWManager sharedManager].isSettedPayPassword = YES;
                    
                }else{//获取是否设置过支付密码失败
                    [MBProgressHUD showError:@"支付密码是否设置结果查询失败"];
                }
                
                //是否有卡
                if([bean.isHaveCard isEqualToString:@"1"]){//you卡
                    
                    DMLog(@"有卡");
                    [YWManager sharedManager].isHasCard = YES;
                    
                }else{//无卡
                    DMLog(@"无卡");
                    [YWManager sharedManager].isHasCard = NO;
                    
                }
                
                
                //是否实人认证
                if([bean.srrz_status isEqualToString:@"1"]){//实人认证通过
                    
                    DMLog(@"实人认证通过");
                    [YWManager sharedManager].isAuthentication = YES;
                }else{//实人认证未通过
                    
                    DMLog(@"实人认证未通过");
                    [YWManager sharedManager].isAuthentication = NO;
                }
                
                //删除极光推送的别名
                
                [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    
                    //DMLog(@"iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
                    
                    //设置个推的别名Alias--设置别名之前要清楚别名
                    [JPUSHService setAlias:bean.push_alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        
                        //DMLog(@"设置别名--iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
                        
                    } seq:0];
                } seq:0];
                
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:@"isLogin" object:nil userInfo:nil];
                [self dismissViewControllerAnimated:NO completion:nil];
                    

            }
    
        } failure:^(NSError *error) {
    
        }];
    
    
}

@end
