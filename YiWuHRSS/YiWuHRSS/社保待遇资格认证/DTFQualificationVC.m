//
//  DTFQualificationVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/21.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFQualificationVC.h"
#import "DTFQualificationConfirmVC.h"
#import "DTFOtherQualificaterVC.h"
#import "HttpHelper.h"

#define URL_IS_ABLE_TO_QUALIFER @"/shebao/attestInformation.json"

@interface DTFQualificationVC ()

@property(nonatomic ,strong) MBProgressHUD * HUD;

@end

@implementation DTFQualificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    HIDE_BACK_TITLE
    
    self.title = @"社保待遇资格认证";
}


/**
 本人认证按钮点击事件

 @param sender 本人认证
 */
- (IBAction)selfQualification:(UIButton *)sender {
    DMLog(@"添加按钮点击");
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"other_id"] = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_IS_ABLE_TO_QUALIFER];
    
    NSLog(@"本人认证资格--URL--%@",url);
    NSLog(@"本人认证资格--param--%@",param);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"本人认证资格-网络请求返回-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            DTFQualificationConfirmVC * vc = [[DTFQualificationConfirmVC alloc]init];
            vc.name = dictData[@"data"][@"name"];
            vc.shbzh = dictData[@"data"][@"shbzh"];
            vc.serialNumber = dictData[@"data"][@"serialNumber"];
            vc.isFromOtherQualiferList = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else{//本人认证资格
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----本人认证资格--请求失败--%@",error);
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}



/**
 非本人认证点击事件

 @param sender 非本人认证
 */
- (IBAction)nonSelfQualification:(UIButton *)sender {
    
    
    DTFOtherQualificaterVC * vc = [[DTFOtherQualificaterVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

- (void)dealloc{

    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

@end
