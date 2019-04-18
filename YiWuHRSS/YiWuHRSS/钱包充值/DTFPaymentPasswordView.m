//
//  DTFPaymentPasswordView.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/11/13.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFPaymentPasswordView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DTFCitizenCardInfoConfirmVC.h"

@interface DTFPaymentPasswordView()

@property (nonatomic ,strong) NSMutableArray * passWordArray;


@property (weak, nonatomic) IBOutlet UIView *passwordView;//密码框
@property (weak, nonatomic) IBOutlet UIView *firstView;//第一个密码
@property (weak, nonatomic) IBOutlet UIView *secondView;//第二个密码
@property (weak, nonatomic) IBOutlet UIView *thirdView;//第三个密码
@property (weak, nonatomic) IBOutlet UIView *fourthView;//第四个密码
@property (weak, nonatomic) IBOutlet UIView *fifthView;//第五个密码
@property (weak, nonatomic) IBOutlet UIView *sixthView;//第六个密码
@property (nonatomic ,strong) NSMutableArray * passWordViewArray;

@property (weak, nonatomic) IBOutlet UIView *pswBgView;





@end


@implementation DTFPaymentPasswordView



-(void)awakeFromNib{
    
    [super awakeFromNib];
    self.passwordView.clipsToBounds = YES;
    self.passwordView.layer.borderColor = [[UIColor colorWithHex:0xeeeeee] CGColor];
    self.passwordView.layer.borderWidth = 1.0;
    
    self.firstView.clipsToBounds = YES;
    self.firstView.layer.cornerRadius = 5.0;
    self.firstView.hidden = YES;
    
    self.secondView.clipsToBounds = YES;
    self.secondView.layer.cornerRadius = 5.0;
    self.secondView.hidden = YES;
    
    self.thirdView.clipsToBounds = YES;
    self.thirdView.layer.cornerRadius = 5.0;
    self.thirdView.hidden = YES;
    
    self.fourthView.clipsToBounds = YES;
    self.fourthView.layer.cornerRadius = 5.0;
    self.fourthView.hidden = YES;
    
    self.fifthView.clipsToBounds = YES;
    self.fifthView.layer.cornerRadius = 5.0;
    self.fifthView.hidden = YES;
    
    self.sixthView.clipsToBounds = YES;
    self.sixthView.layer.cornerRadius = 5.0;
    self.sixthView.hidden = YES;
    
    
}



-(NSMutableArray *)passWordArray{
    
    if(_passWordArray == nil){
        
        _passWordArray = [NSMutableArray array];
    }
    return _passWordArray;
}


-(NSMutableArray *)passWordViewArray{
    
    if(_passWordViewArray == nil){
        self.passWordViewArray = [NSMutableArray array];
        [self.passWordViewArray addObject:self.firstView];
        [self.passWordViewArray addObject:self.secondView];
        [self.passWordViewArray addObject:self.thirdView];
        [self.passWordViewArray addObject:self.fourthView];
        [self.passWordViewArray addObject:self.fifthView];
        [self.passWordViewArray addObject:self.sixthView];
    }
    return _passWordViewArray;
}


/**
 输入支付密码时，点击返回按钮

 @param sender 返回按钮
 */
- (IBAction)backButtonClick:(UIButton *)sender {
    
    //支付密码输入消失动画
    CGRect beforeFrame = self.frame;
    self.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = self.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y + 400, afterFrame.size.width, afterFrame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



- (IBAction)numberButtonClick:(UIButton *)sender {
    
   
    
    //点击0-9的数字按钮
    if((sender.tag - 2000)>0 && (sender.tag - 2000)<11){
        
        DMLog(@"%li",sender.tag - 2000);
        //当输入的密码超过6位时，数组中不再进行添加操作
        if(_passWordArray.count>5) return;
        if((sender.tag - 2000) == 10){
            [self.passWordArray addObject:@"0"];
        }else{
            [self.passWordArray addObject:[NSString stringWithFormat:@"%li",sender.tag - 2000]];
        }
    }
    
    //回退按钮
    if((sender.tag - 2000) == 11){
        if(_passWordArray.count<1) return;
        [_passWordArray removeLastObject];
    }
    

    
    //密码密文显示框中黑点的数目
    for(UIView * view in self.passWordViewArray) {

        if((view.tag - 3000)>0 && (view.tag - 3000)<=self.passWordArray.count){
            view.hidden = NO;
        }else if((view.tag - 3000)>0){
            view.hidden = YES;
        }else{
            view.hidden = NO;
        }
    }
    
    //如果输入完成,回调block
    if(self.passWordArray.count==6){
        NSString * password  = @"";
        for (NSString * character in self.passWordArray) {
            password = [password stringByAppendingString:character];
        }
        DMLog(@"密码输入完成，密码为：%@",password);
        [self removeFromSuperview];
        _completeBlock(password);
    }
    
}


/**
 忘记支付密码按钮点击事件

 @param sender 忘记支付密码按钮点击事件
 */
- (IBAction)forgetPSWButtonClick:(UIButton *)sender {
    
    DMLog(@"忘记支付密码");
    
    self.hidden = YES;
    
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
    DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
    VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
    VC.hidesBottomBarWhenPushed = YES;
    [self.nav pushViewController:VC animated:YES];
    
}


@end
