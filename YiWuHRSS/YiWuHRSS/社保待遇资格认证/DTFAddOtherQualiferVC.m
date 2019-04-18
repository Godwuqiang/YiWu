//
//  DTFAddOtherQualiferVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFAddOtherQualiferVC.h"
#import "HttpHelper.h"
#import "NSString+category.h"

#define URL_ADD_OTHER_QUALIFER  @"shebao/insertOtherInsured.json"
#define kMaxNumber 100

@interface DTFAddOtherQualiferVC ()<UITextFieldDelegate>

/** view距离底部的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewToBottomConstrants;
/** 背景图片距离底部的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageToBottomConstants;
/** 姓名 */
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
/** 社会保障号 */
@property (weak, nonatomic) IBOutlet UITextField *InsureNumberTextField;

/** 添加按钮 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/** 输入的区域是否弹出到键盘的上面 */
@property (assign, nonatomic)  BOOL  isInputAreaUp;

@property(nonatomic ,strong) MBProgressHUD * HUD;


@end

@implementation DTFAddOtherQualiferVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  @"添加其他人信息";
    self.nameTextField.delegate = self;
    self.InsureNumberTextField.delegate = self;
    self.isInputAreaUp = NO;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToUpOrDown)];
    [self.view addGestureRecognizer:tap];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加右侧按钮
    
    //设置添加按钮
    self.addButton.clipsToBounds = YES;
    self.addButton.layer.cornerRadius = 5.0;
    
    //姓名输入框添加限制：只能输入中文和英文
//    [self.nameTextField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.nameTextField.delegate = self;
    
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tap 手势
-(void)tapToUpOrDown{
    
    if(self.isInputAreaUp){//输入区域已经上移
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect navigationBarFrame = CGRectMake(0, 20, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
            self.navigationController.navigationBar.frame = navigationBarFrame;
            CGRect frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.view.frame = frame;
            
        } completion:^(BOOL finished) {
            
        }];

        self.isInputAreaUp = NO;
        [self.nameTextField resignFirstResponder];
        [self.InsureNumberTextField resignFirstResponder];
        
    }else{//输入区域已经下移（初始状态）
        
        [self.nameTextField resignFirstResponder];
        [self.InsureNumberTextField resignFirstResponder];
    }
}


#pragma mark - UITextFieldDelegate

/**
 姓名或者社会保障号开始进行输入

 @param textField 姓名或者社会保障号textField
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect navigationBarFrame = CGRectMake(0, -120, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        self.navigationController.navigationBar.frame = navigationBarFrame;
        CGRect frame =CGRectMake(0, -140, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = frame;
    }];
    self.isInputAreaUp = YES;
}


/**
 姓名或者社会保障号结束进行输入

 @param textField 姓名或者社会保障号textField
 */
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect navigationBarFrame = CGRectMake(0, 20, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        self.navigationController.navigationBar.frame = navigationBarFrame;
        CGRect frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = frame;
    }];
    self.isInputAreaUp = NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.nameTextField){
        
        NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
        
        DMLog(@"键盘输入模式__%@",lang);
        
        if([NSString db_isValidateChineseOrEngnish:string] || [string isEqualToString:@""]){
            return YES;
        }else{
            return NO;
        }
        
    }else{
        
        return YES;
    }
    
    
    
    
    
//    if(textField == self.nameTextField){
//        if ([string validateChineseOrEnglish:string] || [string isEqualToString:@""]) {
//            return YES;
//        }
//        return NO;
//    }
//    return YES;
}


/**
 添加按钮点击事件

 @param sender 添加按钮
 */
- (IBAction)addOtherQualifer:(UIButton *)sender {
    
    DMLog(@"添加按钮点击");
    if(self.nameTextField.text.length == 0){
        
        [MBProgressHUD showError:@"请输入姓名"];
        return ;
    }
    
    if(self.InsureNumberTextField.text.length == 0){
        [MBProgressHUD showError:@"请输入社会保障号"];
        return ;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"name"] = self.nameTextField.text;
    param[@"shbzh"] = self.InsureNumberTextField.text;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,URL_ADD_OTHER_QUALIFER];
    
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"添加其他资格认证人员-网络请求返回-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            [MBProgressHUD showSuccess:dictData[@"message"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.navigationController popViewControllerAnimated:YES];
            });
         
        }else{//非本人认证列表新增成功
            
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        
    } failure:^(NSError *error) {
        
        self.HUD.hidden = YES;
        DMLog(@"DTF----非本人认证列表新增失败--请求失败--%@",error);
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
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"";
}

- (void)dealloc{
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

//#pragma mark -限制姓名只能输入中文和英文
//
//- (void)textFiledDidChange:(UITextField *)textField
//{
//
//    DMLog(@"姓名输入框中只能输入中文和英文");
//    if (kMaxNumber == 0) return;
//
//    NSString *toBeString = textField.text;
//
//    NSLog(@" 打印信息toBeString:%@",toBeString);
//
//    NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
//
//
//    DMLog(@"键盘输入模式__%@",lang);
//
//    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
//
//        //判断markedTextRange是不是为Nil，如果为Nil的话就说明你现在没有未选中的字符，
//        //可以计算文字长度。否则此时计算出来的字符长度可能不正确
//
//        UITextRange *selectedRange = [textField markedTextRange];
//        //获取高亮部分(感觉输入中文的时候才有)
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position)
//        {
//            //中文和字符一起检测  中文是两个字符
//            if ([toBeString getStringLenthOfBytes] > kMaxNumber)
//            {
//                textField.text = [toBeString subBytesOfstringToIndex:kMaxNumber];
//
//            }
//        }
//    }
//    else
//    {
//        if ([toBeString getStringLenthOfBytes] > kMaxNumber)
//        {
//            textField.text = [toBeString subBytesOfstringToIndex:kMaxNumber];
//        }
//    }
//}
//




@end
