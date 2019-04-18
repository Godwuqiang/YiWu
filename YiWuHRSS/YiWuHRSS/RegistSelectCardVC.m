//
//  RegistSelectCardVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistSelectCardVC.h"
#import "RegistBySMCardVC.h"
#import "RegistByHXCardVC.h"


@interface RegistSelectCardVC ()<UIGestureRecognizerDelegate>{

}


@end

@implementation RegistSelectCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
      
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请先选择市民卡类型,再进行注册"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xFDB731] range:NSMakeRange(2,7)];

    self.tit.attributedText = str;
    self.tit.font = [UIFont systemFontOfSize:15];
    //添加手势
    UITapGestureRecognizer * HXCardtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BtnOnclickHXCard)];
    
    UITapGestureRecognizer * SMCardtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BtnOnclickSMCard)];
    HXCardtapGesture.delegate = self;
    SMCardtapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [HXCardtapGesture setNumberOfTapsRequired:1];
    [SMCardtapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.ViewHX addGestureRecognizer:HXCardtapGesture];//和谐卡
    
    [self.ViewSM addGestureRecognizer:SMCardtapGesture];//市民卡
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}


//和谐卡的点击事件
-(void)BtnOnclickHXCard{
    UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
    RegistByHXCardVC * VC = [UB instantiateViewControllerWithIdentifier:@"RegistByHXCardVC"];
    [self.navigationController pushViewController:VC animated:YES];

}

//市民卡的点击事件
-(void)BtnOnclickSMCard{
    UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
    RegistBySMCardVC * VC = [UB instantiateViewControllerWithIdentifier:@"RegistBySMCardVC"];
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
