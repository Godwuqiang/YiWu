//
//  RegistBySMCardVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistBySMCardVC.h"
#import "RegistAccountVC.h"
#import "RegistHttpBL.h"
#import "ValidateCardBean.h"


@interface RegistBySMCardVC ()<RegistHttpBLDelegate,UITextFieldDelegate>{
//    RegistHttpBL         *registHttpBL;
    BOOL                hasnet;
}
@end


@implementation RegistBySMCardVC


-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    self.InputName.delegate = self;
    self.InPutSecoidNum.delegate = self;
    self.InputSMCardNum.delegate = self;
    self.InputBankCardNum.delegate = self;
    
    [self afn];
}

#pragma mark - 点击取消编辑状态
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

#pragma mark - 监听网络状态
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
    
    if (textField==self.InputSMCardNum) {
        NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
            if (character==32) return NO;
            if (character==79 || character==111) return NO;
            if (character < 48) return NO; // 48 unichar for 0
            if (character > 57 && character < 65) return NO; //
            if (character > 90 && character < 97) return NO;
            if (character > 122) return NO;
        }
        
        char commitChar = [string characterAtIndex:0];
        
        if (commitChar > 96 && commitChar < 123)
        {
            //小写变成大写
            
            NSString * uppercaseString = string.uppercaseString;
            
            NSString * str1 = [textField.text substringToIndex:range.location];
            
            NSString * str2 = [textField.text substringFromIndex:range.location];
            
            textField.text = [NSString stringWithFormat:@"%@%@%@",str1,uppercaseString,str2];
            
            return NO;
        }
    }else if (textField==self.InPutSecoidNum || textField==self.InputBankCardNum) {
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    NSString *shbzh     = self.InPutSecoidNum.text;
    NSString *cardno    = self.InputSMCardNum.text;
    NSString *bankCard  = self.InputBankCardNum.text;
    NSString *card_type = @"1";
    
    if ([Util IsStringNil:name]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:nameStr]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入社会保障号"];
        return;
    }
    if ([Util IsStringNil:cardno]) {
        [MBProgressHUD showError:@"请输入市民卡上的卡号"];
        return;
    }
    if ([Util IsStringNil:bankCard]) {
        [MBProgressHUD showError:@"请输入银行卡号"];
        return;
    }

    if (hasnet) {
        [self showLoadingUI];
        RegistHttpBL *registHttpBL = [RegistHttpBL sharedManager];
        registHttpBL.delegate =  self;
        [registHttpBL ValidateCardHttp:nameStr shbzh:shbzh cardno:cardno bankCard:bankCard card_type:card_type];
        
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
    
//    RegistAccountVC * VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistAccountVC"];
//    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 验证卡信息的接口回调
-(void)ValidateCardSucess:(NSString *)success{
    ValidateCardBean *bean = [[ValidateCardBean alloc] init];
    NSString *name      = self.InputName.text;
    NSString *shbzh     = self.InPutSecoidNum.text;
    NSString *cardno    = self.InputSMCardNum.text;
    NSString *bankCard  = self.InputBankCardNum.text;
    bean.name = name;
    bean.shbzh = shbzh;
    bean.cardno = cardno;
    bean.bankCard = bankCard;
    self.HUD.hidden = YES;
    RegistAccountVC * VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegistAccountVC"];
    [VC setValue:@"验证市民卡" forKey:@"Label_title"];
    [VC setBean:bean];
    [VC setType:@"1"];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)ValidateCardFail:(NSString *)error{
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = error;
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:1.5];
    
}

@end
