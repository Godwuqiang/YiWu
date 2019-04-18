//
//  LoginXYVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/30.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "LoginXYVC.h"
//#import "LoginXYCell.h"
#import <WebKit/WebKit.h>


@interface LoginXYVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)   WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation LoginXYVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    [self afn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
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

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [self initView];
        }else{
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            self.navigationItem.title = @"注册协议";
            [self setUpNoNetUI];
        }
    }];
}

#pragma mark - 初始化界面布局
-(void)initView{
    
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
    [self.userContentController addScriptMessageHandler:self  name:@"back"];
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    
    NSString *url = [NSString stringWithFormat:@"%@/information/app_agreement.html",HOST];
    DMLog(@"url=%@",url);
    NSURL *Url = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
}

#pragma mark - 无网络界面
- (void)setUpNoNetUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tsview.hidden = NO;
    self.webView.hidden = YES;
    self.webView.userInteractionEnabled = NO;
}

#pragma mark -  注册H5与原生交互的函数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"%@",message.name);
    DMLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"back"]) {
        [self back];
        return;
    }
}


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

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"agree"];
    [self.userContentController removeScriptMessageHandlerForName:@"back"];
}

@end
