//
//  DTFAuthenticateVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/10/19.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFAuthenticateVC.h"
#import "HttpHelper.h"
//#import <ZMCert/ZMCert.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DTFAuthenticateVC ()

@property (nonatomic, strong) NSString *bizNo;//业务流水号

@end

@implementation DTFAuthenticateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"实人认证";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getZFBAuthResult) name:@"RefreshZhiMaAuthResult" object:@"1"];
    
    [self doVerify:@"https://openapi.alipay.com/gateway.do?alipay_sdk=alipay-sdk-java-dynamicVersionNo&app_id=2017101809373034&biz_content=%7B%22biz_no%22%3A%22ZM201710203000000080800217965543%22%7D&charset=UTF-8&format=json&method=zhima.customer.certification.certify&return_url=YiWuSBIosApp%3A%2F%2FzhimaAuth&sign=Neh7bWIkwthiFjRtDHsr7DkXHrSWKYbjz15%2FrFokLvAhn5r5GzxbP71LNygi5RXRqKaIR3BrmlKUrvA42R6Z8ckCnrZaxAYeb%2Fgwu2%2FJMx8n525cZumHSeQbeGsx39U0bq83LBWHRHxS3FaOItPJRU2Q%2BtalD4oMZcmV5hZd%2FkpvZq6kQtu%2FG1rWee2E%2FpAykzeCHO5EkFgefH6ueeMup6EH%2FYFLD%2BhtlYQ9gaDGBKqYQaU5pz%2Fuc635f9B75p5YyQHefD3q1%2B20Hvky5ithu%2FV7K4G6W0QYUpZo437cayVTqe6bInefFncBp0OJ6IwDjhU3HKxJHTnBOhw4QvvdCg%3D%3D&sign_type=RSA2&timestamp=2017-10-20+17%3A31%3A27&version=1.0&sign=Neh7bWIkwthiFjRtDHsr7DkXHrSWKYbjz15%2FrFokLvAhn5r5GzxbP71LNygi5RXRqKaIR3BrmlKUrvA42R6Z8ckCnrZaxAYeb%2Fgwu2%2FJMx8n525cZumHSeQbeGsx39U0bq83LBWHRHxS3FaOItPJRU2Q%2BtalD4oMZcmV5hZd%2FkpvZq6kQtu%2FG1rWee2E%2FpAykzeCHO5EkFgefH6ueeMup6EH%2FYFLD%2BhtlYQ9gaDGBKqYQaU5pz%2Fuc635f9B75p5YyQHefD3q1%2B20Hvky5ithu%2FV7K4G6W0QYUpZo437cayVTqe6bInefFncBp0OJ6IwDjhU3HKxJHTnBOhw4QvvdCg%3D%3D"];
}


- (void)doVerify:(NSString *)url {
    NSString *alipayUrl = [NSString stringWithFormat:@"alipays://platformapi/startapp?appId=20000067&url=%@", [self URLEncodedStringWithUrl:url]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl] options:@{} completionHandler:nil];
    
//    if ([self canOpenAlipay]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl] options:@{} completionHandler:nil];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否下载并安装支付宝完成认证?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//        [alertView show];
//    }
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

#pragma mark - 获取芝麻认证 跳转需要的URL

-(void)getUrl{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"%@",HOST_TEST];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"返回结果---%@",dictData);
        
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----实人认证--请求失败--%@",error);
    }];
    
    
}


#pragma mark  - 芝麻认证完成 - 回调到本APP - 接收到APP的通知
-(void)getZFBAuthResult{
    
    DMLog(@"DTFAuthenticateVC - 收到芝麻认证回调的通知");
    
}



@end
