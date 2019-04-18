//
//  MainTabBarController.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/11.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "MainTabBarController.h"
#import "JPUSHService.h"
#import "DDLoginVC.h"

#define COMPLEXSERVER_TOKEN_CHECK       @"complexServer/token_check.json"    // token有效性检查
#define COMPLEXSERVER_TOKEN_REFRESH     @"complexServer/token_refresh.json"  // token延长有效期/token置换
#define EXIT_URL                        @"/userServer/login_out.json"        // 退出登录


@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *homeboard = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
    UIStoryboard *serviceboard = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    UIStoryboard *infoboard = [UIStoryboard storyboardWithName: @"Information" bundle: nil];
    UIStoryboard *mineboard = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
    
    UINavigationController *homePageNav = [homeboard instantiateViewControllerWithIdentifier:@"Nav"];
    UINavigationController *servicePageNav = [serviceboard instantiateViewControllerWithIdentifier:@"Nav"];
    UINavigationController *infoPageNav = [infoboard instantiateViewControllerWithIdentifier:@"Nav"];
    UINavigationController *minePageNav = [mineboard instantiateViewControllerWithIdentifier:@"Nav"];
    
    UITabBarItem *homeItem = [[UITabBarItem alloc]initWithTitle:@"首页" image:[UIImage imageNamed:@"icon_home"] tag:1];
    homeItem.selectedImage = [[UIImage imageNamed:@"icon_home_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homePageNav.tabBarItem = homeItem;
    
    UITabBarItem *serviceItem = [[UITabBarItem alloc]initWithTitle:@"服务" image:[UIImage imageNamed:@"icon_sever"] tag:2];
    serviceItem.selectedImage = [[UIImage imageNamed:@"icon_sever_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    servicePageNav.tabBarItem = serviceItem;
    
    UITabBarItem *infoItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"icon_news"] tag:3];
    infoItem.selectedImage = [[UIImage imageNamed:@"icon_news_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    infoPageNav.tabBarItem = infoItem;
    
    UITabBarItem *mineItem = [[UITabBarItem alloc]initWithTitle:@"我的" image:[UIImage imageNamed:@"icon_my"] tag:4];
    mineItem.selectedImage = [[UIImage imageNamed:@"icon_my_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    minePageNav.tabBarItem = mineItem;
    
    self.tabBar.tintColor = [UIColor colorWithHex:0xfdb731];

    self.viewControllers=@[homePageNav,servicePageNav,infoPageNav,minePageNav];
    
    // 第一次启动APP时，检查token有效性
    [self checkTokenValid];
    
    // token失效 重新登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenInvalid:) name:@"token_invalid" object:nil];

    // token超时 刷新token
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenovertime:) name:@"token_overtime" object:nil];
    
}

#pragma mark - 检查token有效性
- (void) checkTokenValid {
    
    if(![CoreArchive boolForKey:LOGIN_STUTAS]){
        return;
    }
    
    DMLog(@"token有效性检查......");
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:version forKey:@"app_version"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,COMPLEXSERVER_TOKEN_CHECK];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"token有效性检查: %@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            NSInteger resultCode = [[resultDict objectForKey:@"resultCode"] integerValue];
            if (resultCode == 200)
            {
                    DMLog(@"token有效性检查成功");
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

/** token失效的通知处理 */
-(void)tokenInvalid:(NSNotification *)notification {
    
    DMLog(@"token失效的通知处理......");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你的账号已在其他设备登录，如非本人操作，登录密码可能已泄露，请修改密码，建议密码与你的其他网站密码不同" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        DMLog(@"点击了立即登录按钮");
        [self queryExit];
//        UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//        DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//        UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//        [self presentViewController:listnav animated:YES completion:nil];
        
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
        
        //如果在业务操作时token失效，返回反导航控制器的第一级
//        NSLog(@"11111111111111111111111111111%@--",self.childViewControllers);
        for (UINavigationController * navVC in self.childViewControllers) {
            
            [navVC popToRootViewControllerAnimated:YES];
        }
    }]];

    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
}

/** token超时的通知处理 */
-(void)tokenovertime:(NSNotification *)notification{
    
    DMLog(@"token超时的通知处理...");
    //置换token
//    [self exchangeToken];
    
    // message 服务端返回
    NSDictionary * userInfo = [notification userInfo];
    NSString *message = userInfo[@"message"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        DMLog(@"点击了立即登录按钮");
        [self queryExit];
//        UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//        DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//        UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//        [self presentViewController:listnav animated:YES completion:nil];
        
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
        
        //如果在业务操作时token失效，返回反导航控制器的第一级
        //        NSLog(@"11111111111111111111111111111%@--",self.childViewControllers);
        for (UINavigationController * navVC in self.childViewControllers) {
            
            [navVC popToRootViewControllerAnimated:YES];
        }
    }]];
    
    //弹出提示框；
    [self presentViewController:alert animated:true completion:nil];
    
}

//#pragma mark - 置换token
//- (void)exchangeToken {
//
//    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:access_token forKey:@"access_token"];
//    [param setValue:@"2" forKey:@"device_type"];
//    [param setValue:version forKey:@"app_version"];
//
//    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,COMPLEXSERVER_TOKEN_REFRESH];
//
//    [HttpHelper post:url params:param success:^(id responseObj) {
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
//        DMLog(@"token延长有效期/token置换: %@",resultDict);
//        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
//            DMLog(@"服务暂不可用，请稍后重试");
//        }else{
//            NSInteger resultCode = [[resultDict objectForKey:@"resultCode"] integerValue];
//            if (resultCode == 200)
//            {
//                NSString *newToken = resultDict[@"data"];
//                [CoreArchive setStr:newToken key:LOGIN_ACCESS_TOKEN];
//            }
//        }
//    } failure:^(NSError *error) {
//        DMLog(@"%@",error);
//    }];
//}


#pragma mark - 退出登录接口
-(void)queryExit {
    
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,EXIT_URL];
    DMLog(@"url=%@",url);
    
    [CoreArchive setBool:NO key:LOGIN_STUTAS];
    [CoreArchive setStr:nil key:LOGIN_ID];
    [CoreArchive setStr:nil key:LOGIN_NAME];
    [CoreArchive setStr:nil key:LOGIN_USER_PSD];
    
    [CoreArchive setStr:nil key:LOGIN_CARD_TYPE];
    [CoreArchive setStr:nil key:LOGIN_CARD_NUM];
    [CoreArchive setStr:nil key:LOGIN_SHBZH];
    [CoreArchive setStr:nil key:LOGIN_BANK];
    
    [CoreArchive setStr:nil key:LOGIN_BANK_CARD];
    [CoreArchive setStr:nil key:LOGIN_USER_PNG];
    [CoreArchive setStr:nil key:LOGIN_CARD_MOBILE];
    [CoreArchive setStr:nil key:LOGIN_BANK_MOBILE];
    
    //[CoreArchive setStr:nil key:LOGIN_APP_MOBILE];
    [CoreArchive setStr:nil key:LOGIN_CARD_STATUS];
    [CoreArchive setStr:nil key:LOGIN_DZYX];
    [CoreArchive setStr:nil key:LOGIN_YJDZ];
    
    [CoreArchive setStr:nil key:LOGIN_CIT_CARDNUM];
    [CoreArchive setStr:nil key:LOGIN_UPDATE_TIME];
    [CoreArchive setStr:nil key:LOGIN_CREATE_TIME];
    [CoreArchive setStr:nil key:LOGIN_ACCESS_TOKEN];
    
    //删除极光推送的别名
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Exit" object:nil userInfo:nil];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"退出登录：=%@",resultDict);
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
