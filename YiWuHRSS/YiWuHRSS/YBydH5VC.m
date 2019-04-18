//
//  YBydH5VC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBydH5VC.h"
#import "YKFPay.h"
#import "LoginVC.h"
#import <WebKit/WebKit.h>

// UIWebViewDelegate,TSWebViewDelegate,JS_YBViewController,

@interface YBydH5VC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)      WKWebView          *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property(nonatomic, strong)      MBProgressHUD       *HUD;

@end

@implementation YBydH5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"医保移动支付";
    HIDE_BACK_TITLE;
    
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    if(kIsiPhoneX){
        topframe = CGRectMake(0,0,SCREEN_WIDTH,45);
    }
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    [self setUpH5];
}
#pragma mark - 初始化及加载H5数据
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
    [self.userContentController addScriptMessageHandler:self  name:@"linkOpenSdk"];//注册一个name为sayhello的js方法
    [self.userContentController addScriptMessageHandler:self  name:@"linkCancelSdk"];
    [self.userContentController addScriptMessageHandler:self  name:@"backRoot"];
    [self.userContentController addScriptMessageHandler:self  name:@"backToTab"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkLogin"];
    [self.userContentController addScriptMessageHandler:self  name:@"getV"];
    
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    NSString *url = [NSString stringWithFormat:@"%@paymentAgreement.html?access_token=%@&device_type=2&openStatus=0",H5_HOST,[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
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
    
    if ([message.name isEqualToString:@"linkOpenSdk"]) {
        [self linkOpenSdk];
        return;
    }
    
    if ([message.name isEqualToString:@"linkCancelSdk"]) {
        [self linkCancelSdk];
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


- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"linkOpenSdk"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkCancelSdk"];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SDK开通业务
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
    DMLog(@"dateString:%@",dateString);
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

#pragma mark - SDK关闭业务
- (void)linkCancelSdk{
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
    DMLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"busName":busName,
                           @"account":account};
    DMLog(@"dict:%@",dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] paymentServiceClose:dict callBack:^(NSDictionary *resultDic){
                DMLog(@"linkCancelSdk resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSString *CODE = [data objectForKey:@"code"];
                if (1000==[CODE intValue]) {
                    [CoreArchive setStr:@"0" key:LOGIN_YDZF_STATUS];
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
                DMLog(@"linkCancelSdk str:%@", str);
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
#pragma mark - 登录拦截函数
- (void)linkLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    });
}

#pragma mark - 数据转JSON
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
