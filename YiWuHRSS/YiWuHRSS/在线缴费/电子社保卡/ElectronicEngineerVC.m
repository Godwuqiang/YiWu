//
//  ElectronicEngineerVC.m
//  YiWuHRSS
//
//  Created by 大白 on 2019/4/10.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import "ElectronicEngineerVC.h"
#import <ZjEsscSDK/ZjEsscSDK.h>
#import "MBProgressHUD.h"
#import "CoreArchive.h"
#import <EsscSDK/EsscSDK.h>

@interface ElectronicEngineerVC ()<EPSecurityManagerDelegate>

@end

@implementation ElectronicEngineerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [EPSecurityManager defaultManager].delegate = self;
    
    [self loadData];
}
#pragma mark - 第一步 获取签名串
-(void)loadData{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];

    NSString *url = [NSString stringWithFormat:@"%@/electronic/card/sign",HOST_TEST];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HttpHelper get:url params:param success:^(id responseObj) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        if([dictData[@"code"] integerValue]==200){
            DMLog(@"参保结果==%@",dictData);
            
            [self validateSignWithSignature:dictData[@"body"][@"urlParams"] shbzh:dictData[@"body"][@"shbzh"]];
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
    } failure:^(NSError *error) {

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}



#pragma mark - 第三步 验证签名串
// signature签名串 以上接口在APP里实现获取签名串，SDK只做签名检验
- (void)validateSignWithSignature:(NSString *)signature shbzh:(NSString *)shbzh{
    
    NSString *urlType = @"portal/#/base/info?";
//    switch (self.type) {
//            //社保卡申领
//        case EsscSceneTypeApplySocialCard:
//            urlType = @"portal/#/base/info?";
//            break;
//            // 电子社保卡
//        case EsscSceneTypeSocialCard:
//            urlType = @"portal/#/base/info?";
//            break;
//            // 电子二维码
//        case EsscSceneTypeIdentifierCodeGenerate:
//            urlType = @"portal/#/qrcode?";
//            break;
//            // 支付密码验证
//        case EsscSceneTypePwdValidation:
//            urlType = @"portal/#/pwd/validate?";
//            break;
//
//            // 短信认证
//        case EsscSceneTypeSmValidation:
//            urlType = @"portal/#/otp/validate?";
//            break;
//            // 人脸识别验证
//        case EsscSceneTypeFaceValidation:
//            urlType = @"portal/#/face/validate?";
//            break;
//            // 身份二维码
//        case EsscSceneTypeIdentity:
//            urlType = @"portal/#/qr?";
//            break;
//            //独立扫码登录
//        case EsscSceneTypeIndependentILogin:
//            urlType = @"portal/#/auth/login?";
//            break;
//    }
//    NSLog(@"名字  %@",[CoreArchive strForKey:LOGIN_NAME]);
    [EPSecurityManager startSdkWithPushVC:self IdCard:shbzh Name:[CoreArchive strForKey:LOGIN_NAME] Url:urlType Sign:signature];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}


- (NSMutableDictionary *)transferDicWithDataStr: (NSString *)jsonStr {
    NSData *newdata = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *newDict =[NSJSONSerialization JSONObjectWithData:newdata options:kNilOptions error:NULL];
    return [NSMutableDictionary dictionaryWithDictionary:[self nullDic:newDict]];
}

//把字典里的NSNull转为""
-(NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = @"";
        }
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

- (void)sdkCallbackSuccessResponseResult:(NSDictionary *)responseResult type:(int)type {
    
    NSString *msg = [self convertToJsonData:responseResult];
    
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        MBProgressHUD *hud = nil;
//        [hud removeFromSuperview];
//
//        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.detailsLabel.text = msg;
//        [hud hideAnimated:YES afterDelay:3.f];
//    });
    NSLog(@"sdkCallbackSuccessResponseResult: %@", msg);
}

- (void)sdkCallbackErrorResponseResult:(id)responseResult error:(NSError *)error {
    
    
    NSString *jsonStr = [[NSString alloc] initWithData:responseResult encoding:NSUTF8StringEncoding];
    NSData *newdata = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *newDict =[NSJSONSerialization JSONObjectWithData:newdata options:NSJSONReadingAllowFragments error:nil];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        MBProgressHUD *hud = nil;
//        [hud removeFromSuperview];
//
//        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        NSString * str = [newDict[@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        hud.detailsLabel.text = str ;
//        [hud hideAnimated:YES afterDelay:3.f];
//    });
    NSLog(@"sdkCallbackErrorResponseResult: %@", newDict);
}

//发卡地返回
- (void)gobackCardIssueView {
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        MBProgressHUD *hud = nil;
//        [hud removeFromSuperview];
//
//        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.detailsLabel.text = @"actionType:'111'" ;
//        [hud hideAnimated:YES afterDelay:3.f];
//    });
    NSLog(@"发卡地点击返回按钮回调");
}
//申领、重置、修改、解除签发回调
- (void)backResponseResult:(id)responseResult error:(NSError *)error {
    
    NSLog(@"//申领、重置、修改、解除签发回调 %@",responseResult);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (responseResult) {
            NSString *resultStr = (NSString *)responseResult;
            NSMutableDictionary *dict =  [self transferDicWithDataStr:resultStr];
            if ([dict[@"actionType"] isEqualToString:@"111"]) {
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            if ([dict[@"actionType"] isEqualToString:@"003"]) {
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            if (![dict[@"actionType"] isEqualToString:@"000"]) {
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
                param[@"signSeq"] = dict[@"signSeq"] ? dict[@"signSeq"] :@"";
                param[@"signLevel"] = dict[@"signLevel"] ? dict[@"signLevel"] :@"";
                param[@"signNo"] = dict[@"signNo"] ? dict[@"signNo"] :@"";
                param[@"validate"] = dict[@"validDate"] ? dict[@"validDate"] :@"";
                param[@"aab301"] = dict[@"aab301"] ? dict[@"aab301"] :@"";
                param[@"signDate"] = dict[@"signDate"] ? dict[@"signDate"] :@"";
                param[@"actionType"] = dict[@"actionType"] ? dict[@"actionType"] :@"";
                param[@"userName"] = dict[@"userName"] ? dict[@"userName"] :@"";
                param[@"userId"] = dict[@"userID"] ? dict[@"userID"] :@"";
                
                NSString *url = [NSString stringWithFormat:@"%@/electronic/card/info/save",HOST_TEST];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [HttpHelper post:url params:param success:^(id responseObj) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
                    if([dictData[@"success"] integerValue]==200){
                        NSLog(@"保存成功");
                    }else{
                        NSLog(@"保存失败");
                    }
                } failure:^(NSError *error) {
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"保存失败");
                }];
                
            }
        }
    });
}
//单独使用某一个功能的场景回调
- (void)backSceneTypeResponseResult:(id)responseResult error:(NSError *)error {
    NSLog( @"This function is %s.\n", __func__ );
    NSLog(@"单独使用某一个功能的场景回调 %@",responseResult);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if (responseResult) {
//            NSString *resultStr = (NSString *)responseResult;
//
//            NSMutableDictionary *dic =  [self transferDicWithDataStr:resultStr];
//            NSString *sceneType = dic[@"sceneType"];
//            if ([sceneType isEqualToString:@"004"]) {
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                hud.mode = MBProgressHUDModeText;
//                hud.detailsLabel.text = @"解绑成功";
//                [hud hideAnimated:YES afterDelay:2.f];
//            }
//
//        }
//    });
}


// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
