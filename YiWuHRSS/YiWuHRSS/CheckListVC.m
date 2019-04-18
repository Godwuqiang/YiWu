//
//  CheckListVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "CheckListVC.h"
#import "YKFPay.h"
#import <WebKit/WebKit.h>
#import "GTMBase64.h"


@interface CheckListVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation CheckListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"检查检验单";
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

#pragma mark - 加载H5界面
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
    [self.userContentController addScriptMessageHandler:self  name:@"backRoot"];//注册一个name为backRoot的js方法
    [self.userContentController addScriptMessageHandler:self  name:@"SH512Sign"];
    [self.userContentController addScriptMessageHandler:self  name:@"linkSdkIdCode"];
    [self.userContentController addScriptMessageHandler:self  name:@"getV"];
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    NSString *url = [NSString stringWithFormat:@"%@hosp_inspect_list.html?access_token=%@&device_type=2&showFlag=2",H5_HOST,[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 注册H5与原生交互界面
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"%@",message.name);
    DMLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"linkSdkIdCode"]) {
        [self linkSdkIdCode];
        return;
    }
    
    if ([message.name isEqualToString:@"backRoot"]) {
        [self backRoot];
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
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"backRoot"];
    [self.userContentController removeScriptMessageHandlerForName:@"SH512Sign"];
    [self.userContentController removeScriptMessageHandlerForName:@"linkSdkIdCode"];
    [self.userContentController removeScriptMessageHandlerForName:@"getV"];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 返回上一界面
- (void)backRoot{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 销毁自身
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - 获取idcode函数
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
    DMLog(@"dict:%@",dict);
    
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
    DMLog(@"NewGetDate:%@",ss2);
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
