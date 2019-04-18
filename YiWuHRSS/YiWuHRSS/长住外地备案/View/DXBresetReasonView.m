//
//  DXBresetReasonView.m
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBresetReasonView.h"

@interface DXBresetReasonView ()<UIGestureRecognizerDelegate>

@end

@implementation DXBresetReasonView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
        self.userInteractionEnabled = YES;
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        
        // 收到下线通知的消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenInvalid) name:@"token_invalid" object:nil];
    }
    return self;
}

- (void)tokenInvalid {
    
     [self removeFromSuperview];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    // 011回原籍居住；012户籍异地落户居住；013随直系亲属异地居住；
    if ([self.reasonType isEqualToString:@"011"]) {
        // 回原籍居住
        
        [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button2 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button3 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button1 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
        [self.button2 setBackgroundColor:[UIColor whiteColor]];
        [self.button3 setBackgroundColor:[UIColor whiteColor]];
    } else if ([self.reasonType isEqualToString:@"012"]) {
        // 户籍异地落户居住
        
        [self.button1 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button3 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button1 setBackgroundColor:[UIColor whiteColor]];
        [self.button2 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
        [self.button3 setBackgroundColor:[UIColor whiteColor]];
        
    } else if ([self.reasonType isEqualToString:@"013"]) {
        // 随直系亲属异地居住
        
        [self.button1 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button2 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button1 setBackgroundColor:[UIColor whiteColor]];
        [self.button2 setBackgroundColor:[UIColor whiteColor]];
        [self.button3 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    }
    
}

- (void)remove {
    
    [self removeFromSuperview];
    
}

- (IBAction)closeBtnClick:(id)sender {
    
     [self removeFromSuperview];
}

#pragma mark - 回原籍居住
- (IBAction)button1Click:(id)sender {
    
    [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button3 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button1 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    [self.button2 setBackgroundColor:[UIColor whiteColor]];
    [self.button3 setBackgroundColor:[UIColor whiteColor]];
    
    self.type(@"1");
    [self removeFromSuperview];
}

#pragma mark - 户籍异地落户居住
- (IBAction)button2Click:(id)sender {
    
    [self.button1 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button3 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button1 setBackgroundColor:[UIColor whiteColor]];
    [self.button2 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    [self.button3 setBackgroundColor:[UIColor whiteColor]];
    
    self.type(@"2");
    [self removeFromSuperview];
}


- (IBAction)button3Click:(id)sender {
    
    [self.button1 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    [self.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button1 setBackgroundColor:[UIColor whiteColor]];
    [self.button2 setBackgroundColor:[UIColor whiteColor]];
    [self.button3 setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    
    self.type(@"3");
    [self removeFromSuperview];
}









@end
