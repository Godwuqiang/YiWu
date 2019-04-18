//
//  DXBResettlementhospitalVC.m
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBResettlementhospitalVC.h"

@interface DXBResettlementhospitalVC ()

@property (nonatomic, strong) UIButton *search3Btn;

@end

@implementation DXBResettlementhospitalVC

- (UIButton *)search3Btn {
    
    if (!_search3Btn) {
        
        _search3Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _search3Btn.frame = CGRectMake(self.search1Btn.frame.origin.x, self.search1Btn.frame.origin.y+self.search1Btn.frame.size.height, self.search1Btn.frame.size.width, self.search1Btn.frame.size.height);
        [_search3Btn setTitle:@"输入" forState:UIControlStateNormal];
    }
    
    
    return _search3Btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"选择安置医院";
    self.view.backgroundColor = [UIColor whiteColor];
    self.search2Btn.layer.cornerRadius = 5;
    
    [self.search1Btn setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
    [self.search1Btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 10)];
    [self.search1Btn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
}


- (IBAction)search1BtnClick:(id)sender {
    
    
    [self.bgView addSubview:self.search3Btn];
}

- (IBAction)search2BtnClick:(id)sender {
    
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
