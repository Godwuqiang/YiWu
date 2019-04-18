//
//  GHH5VC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "GHH5VC.h"
#import "YKFPay.h"
#import "BankXYVC.h"
#import "LoginVC.h"
#import "GTMBase64.h"
#import <WebKit/WebKit.h>


@interface GHH5VC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

//@property (nonatomic, strong) JSContext *jscontext;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation GHH5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"就诊挂号";
    HIDE_BACK_TITLE;
    
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    if(kIsiPhoneX){
        topframe = CGRectMake(0, 0, SCREEN_WIDTH, 45);
    }
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    [self setUpH5];
}

#pragma mark - 初始化H5界面
- (void)setUpH5{
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect bounds = CGRectMake(0, 20, width, height-20);
    if(kIsiPhoneX){
        bounds = CGRectMake(0, 45, width, height-45);
    }
    self.webView = [[WKWebView alloc]initWithFrame:bounds configuration:configuration];
    //注册方法
    [self.userContentController addScriptMessageHandler:self  name:@"linkSdkIdCode"];//注册一个name为sayhello的js方法
    [self.userContentController addScriptMessageHandler:self  name:@"linkBankOpen"];
    [self.userContentController addScriptMessageHandler:self  name:@"getToken"];
    [self.userContentController addScriptMessageHandler:self  name:@"statusQuery"];
    [self.userContentController addScriptMessageHandler:self  name:@"backRoot"];
    [self.userContentController addScriptMessageHandler:self  name:@"backToTab"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkOpenSdk"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkLogin"];
    [self.userContentController addScriptMessageHandler:self  name:@"SH512Sign"];
    [self.userContentController addScriptMessageHandler:self  name:@"goToPay"];
    [self.userContentController addScriptMessageHandler:self  name:@"getV"];
    
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    NSString *url = [NSString stringWithFormat:@"%@goRegister.html?access_token=%@&device_type=2&pageNo=1&pageSize=3",H5_HOST,[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
    DMLog(@"url=%@",url);
    NSURL *Url = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self showLoadingUI];
    [self.webView loadRequest:request];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    self.HUD.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.HUD.hidden = YES;
}

#pragma mark - 注册H5与原生交互函数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"H5调用APP的方法名称：%@",message.name);
    DMLog(@"H5调用APP的方法内容：%@",message.body);
    
    if ([message.name isEqualToString:@"linkSdkIdCode"]) {
        [self linkSdkIdCode];
        return;
    }
    
    if ([message.name isEqualToString:@"linkBankOpen"]) {
        [self linkBankOpen];
        return;
    }
    
    if ([message.name isEqualToString:@"getToken"]) {
        [self getToken];
        return;
    }
    
    if ([message.name isEqualToString:@"statusQuery"]) {
        [self statusQuery];
        return;
    }
    
    if ([message.name isEqualToString:@"backRoot"]) {
        [self backRoot];
        return;
    }
    
    if ([message.name isEqualToString:@"backToTab"]) {
        [self backToTab];
        return;
    }
    
    if ([message.name isEqualToString:@"linkOpenSdk"]) {
        [self linkOpenSdk];
        return;
    }
    
    if ([message.name isEqualToString:@"linkLogin"]) {
        [self linkLogin];
        return;
    }
    
    if ([message.name isEqualToString:@"SH512Sign"]) {
        @try {
            NSDictionary  *body = message.body;
            NSString *bb = [body valueForKey:@"body"];
            [self SHSign:bb];
        } @catch (NSException *exception) {
            NSString *str = @"解析错误";
            [MBProgressHUD showError:str];
        }
        return;
    }
    
    if([message.name isEqualToString:@"getV"]){
        
        NSString * app_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *str = [NSString stringWithFormat:@"returnAPPVersion('%@')",app_version];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            }];
        });
    }
    
    if([message.name isEqualToString:@"goToPay"]){
        
        NSLog(@"message.body===%@",message.body);
        NSString * paramString = message.body[@"body"];
        NSArray * paramArray = [paramString componentsSeparatedByString:@","];
        NSString * billsId = paramArray[0];//处方临时账单ID
        NSString * payChannel = paramArray[1];//支付渠道（2：支付宝 4：微信）
        NSString * isMedicare = paramArray[2];//是否自费（0：是 1：否）
        NSString * userId = paramArray[3];//用户ID
        
        NSString *platform = @"107135e01f964cc7abd6b2941d879434";
        NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
        NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
        NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
        NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
        
        NSString *cardtype;
        NSString *cardnum;
        if ([type isEqualToString:@"1"]) {
            cardtype = @"100";
            cardnum = [Util HeadStr:kh WithNum:1];
        }else{
            cardtype = @"730";
            cardnum = @"";
        }
        NSString *account = [Util HeadStr:bk WithNum:1];
        NSString *name = [CoreArchive strForKey:LOGIN_NAME];
        NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
        sbh = [Util HeadStr:sbh WithNum:1];
        
        
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        DMLog(@"dateString:%@",dateString);
        NSString *comTime = dateString;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = userId;
        dic[@"cardType"] = cardtype;
        dic[@"cardNum"] = cardnum;//[CoreArchive strForKey:DZSBK_INSURE_CARD_NUM];
        dic[@"account"] = account;//[CoreArchive strForKey:DZSBK_BANK_CARD];
        dic[@"name"] = name;//[CoreArchive strForKey:DZSBK_USER_NAME];
        dic[@"type"] = payChannel;
        
        dic[@"isMedicare"] = isMedicare;
        dic[@"billsId"] = billsId;
        dic[@"idCard"] = sbh;//[CoreArchive strForKey:DZSBK_ID_CARD];
        dic[@"platform"] = platform;
        dic[@"apikey"] = apikey;
        dic[@"comTime"] = comTime;
        
        NSLog(@"立即支付===%@",dic);
        
        [[YKFPay shareYKFPay] billPaymentWithDic:dic viewController:self callBack:^(NSDictionary
                                                                                    *resultDic) {
            NSLog(@"支付成功回调resultDic==%@",resultDic);
            if ([resultDic[@"code"] integerValue] == 1000) {
                // 付成功
                NSString *billId = resultDic[@"billId"];
                NSString *str = [NSString stringWithFormat:@"returnId('%@')",billId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"%@",result);
                    }];
                });
            } }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    if (self.jscontext) {
//        self.jscontext= nil;
//    }
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"linkSdkIdCode"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkBankOpen"];
    [self.userContentController removeScriptMessageHandlerForName:@"getToken"];
    [self.userContentController removeScriptMessageHandlerForName:@"statusQuery"];
    [self.userContentController removeScriptMessageHandlerForName:@"backRoot"];
    [self.userContentController removeScriptMessageHandlerForName:@"backToTab"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkOpenSdk"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkLogin"];
    [self.userContentController removeScriptMessageHandlerForName:@"SH512Sign"];
    [self.userContentController removeScriptMessageHandlerForName:@"goToPay"];
    [self.userContentController removeScriptMessageHandlerForName:@"getV"];
    
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

#pragma mark - 获取idcode
- (void)linkSdkIdCode{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    DMLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    NSString *name = [CoreArchive strForKey:LOGIN_NAME];
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"name":name,
                           @"account":account};
    DMLog(@"获取idcode==dict:%@",dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] obtainIdCode:dict callBack:^(NSDictionary *resultDic) {
                DMLog(@"ghcode resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *CODE = [data objectForKey:@"code"];
                NSString *idCode;
                if (1000==[CODE intValue]) {
                    idCode = [data objectForKey:@"idCode"];
                }else{
                    idCode = [data objectForKey:@"msg"];
                    [MBProgressHUD showError:idCode];
                    idCode = @"";
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *str = [NSString stringWithFormat:@"returnCode('%@')",idCode];
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"%@",result);
                    }];
                });
            }];
        } @catch (NSException *exception) {
            DMLog(@"ghexception:%@",exception);
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    });
}

#pragma mark - 获取authToken
- (void)getToken{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    NSString *name = [CoreArchive strForKey:LOGIN_NAME];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    DMLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"name":name,
                           @"account":account};
    DMLog(@"dict:%@",dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] obtainAuthToken:dict callBack:^(NSDictionary *resultDic) {
                DMLog(@"ghtoken resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *authToken = [self DataTOjsonString:data];
                authToken = [authToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
                authToken = [authToken stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                authToken = [authToken stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                authToken = [authToken stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                authToken = [authToken stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                DMLog(@"authToken=%@",authToken);
                NSString *str = [NSString stringWithFormat:@"returnToken('%@')",authToken];
                DMLog(@"%@",str);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"result=%@",result);
                    }];
                });
            }];
        } @catch (NSException *exception) {
            DMLog(@"ghexception:%@",exception);
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    });
}

#pragma mark - 字符串转换成JSON
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        DMLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - 获取认证结果
- (void)statusQuery{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    DMLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"account":account};
    DMLog(@"dict:%@",dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] obtainAuthResult:dict callBack:^(NSDictionary *resultDic) {
                DMLog(@"ghtoken resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *CODE = [data objectForKey:@"code"];
                NSString *status;
                if (1000==[CODE intValue]) {
                    status = [data objectForKey:@"hospMobpay"];
                }else{
                    status = [data objectForKey:@"msg"];
                    [MBProgressHUD showError:status];
                    status = @"";
                }
                NSString *str = [NSString stringWithFormat:@"returnStatus('%@')",status];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"%@",result);
                    }];
                });
            }];
        } @catch (NSException *exception) {
            DMLog(@"ghexception:%@",exception);
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    });
}

#pragma mark - 银行卡开通拦截
- (void)linkBankOpen{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        BankXYVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankXYVC"];
        [VC setValue:@"gh" forKey:@"lx"];
        [self.navigationController pushViewController:VC animated:YES];
    });
}

#pragma mark - 返回上一界面
- (void)backRoot{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 销毁自身
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - 返回根目录
-(void)backToTab{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated: YES ];
    });
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        if ([challenge previousFailureCount] == 0) {
            
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
        } else {
            
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            
        }
        
    } else {
        
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);   
        
    }
}

#pragma mark - 医保移动支付开通函数
- (void)linkOpenSdk{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    NSString *busName = @"医保移动支付";
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"busName":busName,
                           @"account":account};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] paymentServiceOpening:dict callBack:^(NSDictionary *resultDic){
                DMLog(@"linkOpenSdk resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *CODE = [data objectForKey:@"code"];
                if (1000==[CODE intValue]) {
                    [CoreArchive setStr:@"1" key:LOGIN_YDZF_STATUS];
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:@"isLogin" object:nil userInfo:nil];
                }
                NSString *cc = [self DataTOjsonString:data];
                cc = [cc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
                cc = [cc stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                cc = [cc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                cc = [cc stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                cc = [cc stringByReplacingOccurrencesOfString:@" " withString:@""];
                DMLog(@"CODE=%@",cc);
                
                NSString *str = [NSString stringWithFormat:@"returnCode('%@')",cc];
                DMLog(@"linkOpenSdk str:%@", str);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"result=%@",result);
                    }];
                });
            }];
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    });
}

#pragma mark - 登录拦截函数
- (void)linkLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    });
}

#pragma mark - SH512加密函数
-(void)SHSign:(NSString*)str{
    NSData *data1 = [str dataUsingEncoding:NSASCIIStringEncoding];
    NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableContainers error:NULL];
    NSDate *dates = [NSDate date];
    NSTimeInterval interval = 60 * 2;
    NSDate *detea = [NSDate dateWithTimeInterval:interval sinceDate:dates];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"BeiJing"];
    [dateformatter setTimeZone:timeZone];
    NSString *locationString=[dateformatter stringFromDate:detea];
    DMLog(@"locationString:%@",locationString);

    [dic1 setValue:locationString forKey:@"exp"];
    
    NSArray *arr = [self stepOne:dic1];
    NSString *pj = [self stepTwo:arr];
    DMLog(@"pj:%@",pj);
    NSMutableString *sh512str = [self SH512Sign:pj];
    DMLog(@"sh512str:%@",sh512str);
    
    [dic1 setValue:sh512str forKey:@"sign"];
    
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:dic1 options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *ss = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
    NSString *ss1 = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *ss2 = [ss1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    DMLog(@"加密--测试--NewGetDate:%@",ss2);
    NSString *mima = [NSString stringWithFormat:@"NewGetDate('%@')",ss2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:mima completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            DMLog(@"%@",result);
            DMLog(@"%@",error);
        }];
    });
}

#pragma mark - 除去请求参数中空值和签名参数sign和sign_type不加入签名 并组成数组形式返回
-(NSArray*)stepOne:(NSDictionary*)dict{
    NSMutableArray * muArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * allkeys = [dict allKeys];
    DMLog(@"allkeys %@",allkeys);
    
    for (int i = 0; i < allkeys.count; i++)
    {
        NSString * key = [allkeys objectAtIndex:i];
        //如果你的字典中存储的多种不同的类型,那么最好用id类型去接受它
        id obj  = [dict objectForKey:key];
        if (![key isEqualToString:@"sign"]&&![key isEqualToString:@"sign_type"]) {
            if ([obj isKindOfClass:[NSString class]]){
                if (![obj isEqualToString:@""]) {
                    NSString *tb = [NSString stringWithFormat:@"%@=%@",key,obj];
                    [muArray addObject:tb];
                }
            }else{
                if (![obj isKindOfClass:[NSNull class]]){
                    NSString *tb = [NSString stringWithFormat:@"%@=%@",key,obj];
                    [muArray addObject:tb];
                }
            }
        }
    }
    
    NSArray *myArray = [muArray copy];
    
    return myArray;
}

#pragma mark - 对数组按照ASCII由小到大排序,并按要求拼接成字符串
-(NSString*)stepTwo:(NSArray*)arr{
    
    NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch|NSNumericSearch|
    
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        
        NSRange range =NSMakeRange(0,obj1.length);
        
        return [obj1 compare:obj2 options:comparisonOptions range:range];
        
    };
    
    NSArray *arr2 = [arr sortedArrayUsingComparator:sort];
    
    NSString *str = @"";
    for (int i=0; i<arr2.count-1; i++) {
        str = [str stringByAppendingFormat:@"%@&", arr2[i]];
    }
    str = [str stringByAppendingFormat:@"%@", arr2[arr2.count-1]];
    str = [str stringByAppendingFormat:@"%@", @"544BFCD7B77AA5B0CE22F86F7AB0E722"];
    
    return str;
}

#pragma mark - SHA512加密
-(NSMutableString*)SH512Sign:(NSString*)str{
    const char *cstr = [str UTF8String];
//    使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
//    使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA512(cstr, strlen(cstr), digest);
    NSMutableString* ret = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", digest[i]];
    }
    return ret;
}

@end
