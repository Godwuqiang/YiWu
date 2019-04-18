//
//  DTFAccessSelectView.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFAccessSelectView.h"

@interface DTFAccessSelectView ()

@property (weak, nonatomic) IBOutlet UIButton *firstButton;     //自取
@property (weak, nonatomic) IBOutlet UIButton *secondButton;    //邮寄

@end

@implementation DTFAccessSelectView

-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToView)];
    [self addGestureRecognizer:tap];
    
    [self.firstButton setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.firstButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.secondButton setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.secondButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    // 收到下线通知的消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenInvalid) name:@"token_invalid" object:nil];
}

- (void)tokenInvalid {
    
    [self removeFromSuperview];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    // 登记表获取方式 1自取；2邮寄；
    if ([self.djbhqfs isEqualToString:@"1"]) {
        // 自取
        self.firstButton.backgroundColor = [UIColor colorWithHex:0xFEAF29];
        self.secondButton.backgroundColor = [UIColor whiteColor];
        self.firstButton.selected = YES;
        self.secondButton.selected = NO;
       
    } else if ([self.djbhqfs isEqualToString:@"2"]) {
        // 邮寄
        
        self.secondButton.backgroundColor = [UIColor colorWithHex:0xFEAF29];
        self.firstButton.backgroundColor = [UIColor whiteColor];
        self.secondButton.selected = YES;
        self.firstButton.selected = NO;
        
    }
    
}


/**
 关闭按钮点击事件

 @param sender 关闭按钮
 */
- (IBAction)closeButtonClick:(UIButton *)sender {
    
    
    [self removeFromSuperview];
}


-(void)tapToView{
    
    if(self.firstButton.selected){
        self.selectedType(@"1");
    }else if (self.secondButton.selected){
        self.selectedType(@"2");
    }else{
        self.selectedType(@"");
    }
    [self removeFromSuperview];
}


/**
 自取按钮点击事件

 @param sender 自取
 */
- (IBAction)firstButtonClick:(UIButton *)sender {
    
    self.firstButton.backgroundColor = [UIColor colorWithHex:0xFEAF29];
    self.secondButton.backgroundColor = [UIColor whiteColor];
    self.firstButton.selected = YES;
    self.secondButton.selected = NO;
    self.selectedType(@"1");
    [self removeFromSuperview];
    
}


/**
 邮寄按钮点击事件

 @param sender 邮寄
 */
- (IBAction)secondButtonClick:(UIButton *)sender {
    
    self.secondButton.backgroundColor = [UIColor colorWithHex:0xFEAF29];
    self.firstButton.backgroundColor = [UIColor whiteColor];
    self.secondButton.selected = YES;
    self.firstButton.selected = NO;
    self.selectedType(@"2");
    [self removeFromSuperview];
}

@end


