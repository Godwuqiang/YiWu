//
//  BankXYVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BankXYVC.h"
//#import "BtnCell.h"
//#import "NSXYCell.h"
//#import "CZXYCell.h"
//#import "XYCell.h"
#import "BankZFVC.h"
#import <WebKit/WebKit.h>


@interface BankXYVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)   NSString  *xy;

@property (nonatomic, strong)   WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation BankXYVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    if(kIsiPhoneX){
        topframe = CGRectMake(0,0,SCREEN_WIDTH,45);
    }
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    DMLog(@"lx=%@",self.lx);
    [self initView];

}

- (void)viewWillAppear:(BOOL)animated{
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
}


- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"agree"];
    [self.userContentController removeScriptMessageHandlerForName:@"back"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化及加载H5
-(void)initView{

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
    
    [self.userContentController addScriptMessageHandler:self  name:@"agree"];
    [self.userContentController addScriptMessageHandler:self  name:@"back"];
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    
    NSString *yh = [CoreArchive strForKey:LOGIN_BANK_CODE];
    NSString *url;
    if ([yh isEqualToString:@"6000"]) {
//        url = [NSString stringWithFormat:@"%@/information/pay_agreement1.html",HOST];
        url = @"https://app.ywrl.gov.cn:8554/information/pay_agreement1.html";
    }else{
//        url = [NSString stringWithFormat:@"%@/information/pay_agreement2.html",HOST];
        url = @"https://app.ywrl.gov.cn:8554/information/pay_agreement2.html";
    }
    
    DMLog(@"url=%@",url);
    NSURL *Url = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
}

#pragma mark - 注册H5与原生交互的函数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"%@",message.name);
    DMLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"agree"]) {
        [self agree];
    }
    
    if ([message.name isEqualToString:@"back"]) {
        [self back];
        return;
    }
}

#pragma mark - 跳转到下一界面
-(void)agree{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        BankZFVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankZFVC"];
        [self.navigationController pushViewController:VC animated:NO];
    });
}

#pragma mark - 返回
-(void)back{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 销毁自身
        [self.navigationController popViewControllerAnimated:NO];
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
