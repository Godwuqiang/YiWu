//
//  InfoVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/12.
//  Copyright © 2016年 许芳芳. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "InfoVC.h"
#import "BdH5VC.h"


@interface InfoVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;
@property(nonatomic, strong)   MBProgressHUD    *HUD;
@property (nonatomic, strong)  UIImageView      *nodata;
@property (nonatomic, strong)  UILabel          *tit;
@property (nonatomic, strong)  UIButton         *refreshbtn;
@property (nonatomic, strong)  UIView         *addView;
//@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation InfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.title = @"资讯";
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,45);
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    [self setUpUI];
   
    self.navigationItem.title = @"资讯";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setupNavigationBarStyle];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   [self afn];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
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

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"WiFi||4G");
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [self setUpH5];
        }else{
            DMLog(@"未知");
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self setUpNoNetUI];
        }
    }];
}

#pragma mark - 初始化界面布局
- (void)setUpUI{

    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    //注册方法
    [self.userContentController addScriptMessageHandler:self name:@"openDetail"]; // 咨询详情页
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect bounds = CGRectMake(0, 20, width, height-20);
    if(kIsiPhoneX){
        bounds = CGRectMake(0, 45, width, height-45);
    }
    self.webView = [[WKWebView alloc]initWithFrame:bounds configuration:configuration];
    [self.view addSubview:self.webView];
    self.webView.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nodata = [[UIImageView alloc] init];
    [self.view addSubview:self.nodata];
    [self.nodata mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.centerY.equalTo(weakSelf.view.mas_centerY).offset(-30);
        make.width.equalTo(@200);
        make.height.equalTo(@170);
    }];
    self.nodata.image = [UIImage imageNamed:@"img_noweb"];
    self.nodata.hidden = YES;
    
    self.tit = [[UILabel alloc]init];
    [self.view addSubview:self.tit];
    [self.tit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nodata.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(@245);
        //        make.height.equalTo(@15);
    }];
    self.tit.numberOfLines = 0;
    self.tit.text = @"当前网络不可用，请检查网络设置";
    self.tit.textAlignment = NSTextAlignmentCenter;
    self.tit.textColor = [UIColor colorWithHex:0x999999];
    self.tit.font = [UIFont systemFontOfSize:15];
    self.tit.hidden = YES;
    
    self.refreshbtn = [[UIButton alloc]init];
    [self.view addSubview:self.refreshbtn];
    [self.refreshbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tit.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@45);
    }];
    [self.refreshbtn setBackgroundImage:[UIImage imageNamed:@"btn_submit"] forState:UIControlStateNormal];
    [self.refreshbtn setTitle:@"重新刷新" forState:UIControlStateNormal];
    [self.refreshbtn addTarget:self action:@selector(refresh404) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.refreshbtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.refreshbtn.hidden = YES;
}

- (void)setUpH5{
    
    self.webView.hidden = NO;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.bouncesZoom = NO;
    self.nodata.hidden = YES;
    self.tit.hidden = YES;
    self.refreshbtn.hidden = YES;

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *url = [NSString stringWithFormat:@"%@/h5/news_list.html?app_version=%@",HOST,version];
    NSURL *Url = [NSURL URLWithString:url];
    DMLog(@"url=%@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
    [self showLoadingUI];
}

#pragma mark - 显示无网界面
- (void)setUpNoNetUI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_noweb"];
    self.tit.hidden = NO;
    self.tit.text = @"当前网络不可用，请检查网络设置";
    self.refreshbtn.hidden = YES;
    self.HUD.hidden = YES;
}

#pragma mark - 显示404界面
-(void)setup404UI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_404"];
    self.tit.hidden = NO;
    self.tit.text = @"页面走丢了，请稍后重试~";
    self.refreshbtn.hidden = NO;
    self.HUD.hidden = YES;
}

#pragma mark - 刷新404界面
-(void)refresh404{
    [self afn];
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
        decisionHandler (WKNavigationResponsePolicyAllow);
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self setup404UI];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

#pragma mark - 配置H5与原生交互方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"name:%@",message.name);
    DMLog(@"body:%@",message.body);
    
    if ([message.name isEqualToString:@"openDetail"]) {
        
        UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
        BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:message.body forKey:@"url"];
        [VC setValue:@"详情" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
        return;
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
    [self.userContentController removeScriptMessageHandlerForName:@"openDetail"];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

@end
