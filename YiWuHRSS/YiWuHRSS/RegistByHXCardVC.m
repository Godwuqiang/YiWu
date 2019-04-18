//
//  RegistByHXCardVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistByHXCardVC.h"
#import "RegistAccountVC.h"
#import "RegistHttpBL.h"
#import "ValidateCardBean.h"


@interface RegistByHXCardVC ()<RegistHttpBLDelegate,UITextFieldDelegate>{
    RegistHttpBL         *registHttpBL;
    BOOL                hasnet;
}
@end

@implementation RegistByHXCardVC


-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
    
    self.InputName.delegate = self;
    self.InputSHnum.delegate = self;
    self.InputBankNum.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    registHttpBL = [RegistHttpBL sharedManager];
    registHttpBL.delegate =  self;
    [self afn];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setupNavigationBarStyle];
//    [self afn];
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

-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            hasnet = YES;
        }else{
            hasnet = NO;
        }
    }];
}


/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"信息校验中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([Util IsStringNil:string])
    {
        return YES;
    }
    
    if (textField==self.InputSHnum || textField==self.InputBankNum) {
        NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
            if (character==32) return NO;
        }
    }else{
        return YES;
    }
    return YES;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 点击下一步按钮
- (IBAction)OnClickNextAction:(id)sender {
    NSString *name      = self.InputName.text;
    NSString *nameStr = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    DMLog(@"nameStr=%@",nameStr);
    NSString *shbzh     = self.InputSHnum.text;
    NSString *cardno    = @"";
    NSString *bankCard  = self.InputBankNum.text;
    NSString *card_type = @"2";//和谐卡
    
    if ([Util IsStringNil:name]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:nameStr]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入身份证号码"];
        return;
    }
    if ([Util IsStringNil:bankCard]) {
        [MBProgressHUD showError:@"请输入银行卡号"];
        return;
    }
    
    if (hasnet) {
        [self showLoadingUI];
        [registHttpBL ValidateCardHttp:nameStr shbzh:shbzh cardno:cardno bankCard:bankCard card_type:card_type];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 验证卡信息的接口回调
-(void)ValidateCardSucess:(NSString *)success{
    ValidateCardBean *bean = [[ValidateCardBean alloc] init];
    NSString *name      = self.InputName.text;
    NSString *shbzh     = self.InputSHnum.text;
    NSString *cardno    = @"";
    NSString *bankCard  = self.InputBankNum.text;
    bean.name = name;
    bean.shbzh = shbzh;
    bean.cardno = cardno;
    bean.bankCard = bankCard;
    self.HUD.hidden = YES;
    RegistAccountVC * VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistAccountVC"];
    [VC setValue:@"验证市民卡" forKey:@"Label_title"];
    [VC setBean:bean];
    [VC setType:@"2"];
    [self.navigationController pushViewController:VC animated:YES];
    
}

-(void)ValidateCardFail:(NSString *)error{
    [MBProgressHUD showError:error];
    self.HUD.hidden = YES;
}

@end
