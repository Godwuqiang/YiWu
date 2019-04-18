//
//  MineWebVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "MineWebVC.h"
#import "RealPersonVC.h"
#import "LoginVC.h"
#import "HttpHelper.h"
#import <WebKit/WebKit.h>

//UIWebViewDelegate,TSWebViewDelegate,JS_TSViewController,

@interface MineWebVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) NSString *h5str;
@property (nonatomic, strong) NSString *bankmobile;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation MineWebVC

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

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setupNavigationBarStyle];
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
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
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
    self.webView = [[WKWebView alloc]initWithFrame:bounds configuration:configuration];

    //注册方法
    [self.userContentController addScriptMessageHandler:self  name:@"linktoPic"];
    [self.userContentController addScriptMessageHandler:self  name:@"backRoot"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkLogin"];
    [self.userContentController addScriptMessageHandler:self  name:@"getV"];
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.hidden = NO;
    
    NSString *url = [NSString stringWithFormat:@"%@authentication.html?access_token=%@&device_type=2",H5_HOST,[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
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
    
    if ([message.name isEqualToString:@"linktoPic"]) {
 
        @try {
            NSDictionary  *body = message.body;
            NSString *bb = [body valueForKey:@"body"];
            NSArray *listItems = [bb componentsSeparatedByString:@","];
            NSString *data = listItems[0];
            NSString *phone = listItems[1];
            DMLog(@"data=%@,phone=%@",data,phone);
            [self linkto:data Pic:phone];
        } @catch (NSException *exception) {
            NSString *str = @"解析错误";
            [MBProgressHUD showError:str];
        }

        return;
    }
    
    if ([message.name isEqualToString:@"backRoot"]) {
        [self backRoot];
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
    [self.userContentController removeScriptMessageHandlerForName:@"linktoPic"];
    [self.userContentController removeScriptMessageHandlerForName:@"backRoot"];
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

#pragma mark - 传参到拍照界面
- (void)linkto:(NSString *)str Pic:(NSString*)phone{
    dispatch_async(dispatch_get_main_queue(), ^{
        RealPersonVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RealPersonVC"];
        [VC setValue:str forKey:@"str"];
        [VC setValue:phone forKey:@"phone"];
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

#pragma mark - 登录拦截函数
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
