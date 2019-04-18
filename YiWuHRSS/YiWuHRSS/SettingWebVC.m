//
//  SettingWebVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "SettingWebVC.h"
#import "YKFPay.h"
#import "SettingWebVC.h"
#import "LoginVC.h"
#import <WebKit/WebKit.h>

//UIWebViewDelegate,TSWebViewDelegate,JS_SettingWebVC,

@interface SettingWebVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation SettingWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"实人认证";
    HIDE_BACK_TITLE;
    
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    [self setUpH5];
}

#pragma mark - 初始化及加载H5数据
- (void)setUpH5{
    DMLog(@"phone:%@",self.phone);
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect bounds = CGRectMake(0, 20, width, height-20);
    self.webView = [[WKWebView alloc]initWithFrame:bounds configuration:configuration];

    //注册方法
    [self.userContentController addScriptMessageHandler:self  name:@"linktoSdk"];
    [self.userContentController addScriptMessageHandler:self  name:@"backRoot"];
    [self.userContentController addScriptMessageHandler:self  name:@"backToTab"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkLogin"];
    [self.userContentController addScriptMessageHandler:self  name:@"getV"];

    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    NSString *url = [NSString stringWithFormat:@"%@setPassword.html?access_token=%@&device_type=2&phone=%@",H5_HOST,[CoreArchive strForKey:LOGIN_ACCESS_TOKEN],self.phone];
    DMLog(@"url=%@",url);
    NSURL *Url = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
    [self showLoadingUI];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}


- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    self.HUD.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.HUD.hidden = YES;
}

#pragma mark - 注册H5与原生交互函数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"%@",message.name);
    DMLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"linktoSdk"]) {
        [self linktoSdk];
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
    
    if ([message.name isEqualToString:@"linkLogin"]) {
        [self linkLogin];
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"linktoSdk"];
    [self.userContentController removeScriptMessageHandlerForName:@"backRoot"];
    [self.userContentController removeScriptMessageHandlerForName:@"backToTab"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkLogin"];
    [self.userContentController removeScriptMessageHandlerForName:@"getV"];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 设置支付密码
-(void)linktoSdk{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    NSString *shbzh = [Util HeadStr:[CoreArchive strForKey:LOGIN_SHBZH] WithNum:1];
    
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
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    if ([Util IsStringNil:_str]) {
        dict = @{@"platform":platform,
                 @"apikey":apikey,
                 @"cardType":cardtype,
                 @"certNum":shbzh,
                 @"comTime":comTime,
                 @"cardNum":cardnum,
                 @"str":_str,
                 @"account":account};
    }else{
        dict = @{@"platform":platform,
                 @"apikey":apikey,
                 @"cardType":cardtype,
                 @"certNum":shbzh,
                 @"comTime":comTime,
                 @"cardNum":cardnum,
                 @"str":_str,
                 @"serNum":_str,
                 @"account":account};
    }
    
    DMLog(@"dict:%@",dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] setPassword:dict callBack:^(NSDictionary *resultDic) {
                DMLog(@"resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *CODE = [data objectForKey:@"code"];
                if (1000==[CODE intValue]) {
                    [CoreArchive setStr:@"1" key:LOGIN_SRRZ_STATUS];
                    [CoreArchive setStr:@"1" key:LOGIN_SET_PAY_PSW];
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:@"isLogin" object:nil userInfo:nil];
                    
                }else{
                    NSString *msg = [resultDic objectForKey:@"msg"];
                    [MBProgressHUD showError:msg];
                    CODE = @"";
                }
                NSString *str = [NSString stringWithFormat:@"returnCode('%@')",CODE];
                DMLog(@"returnCode str=%@",str);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        DMLog(@"%@",result);
                    }];
                    
                    //返回到等页面
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                        [center postNotificationName:@"regist_setPayPassword_finish" object:nil userInfo:nil];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                    
                });
            }];
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
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

#pragma mark - 登录拦截
- (void)linkLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];

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

@end
