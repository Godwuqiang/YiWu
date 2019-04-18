//
//  DTFRegisterVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFRegisterVC.h"
#import "DTFNoticeVC.h"

@interface DTFRegisterVC ()

@property (weak, nonatomic) IBOutlet UIView *remoteView;//异地安置登记
@property (weak, nonatomic) IBOutlet UIView *visitFamilyView;//探亲登记
@property (weak, nonatomic) IBOutlet UIView *expatriateView;//外派人员登记
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;


@end

@implementation DTFRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    
}


-(void)setupUI{
    
    
    self.topConstrains.constant += 20;
    
    self.title = @"长住外地备案";
    self.remoteView.clipsToBounds = YES;
    self.remoteView.layer.borderColor = [UIColor colorWithHex:0xfdb731].CGColor;
    self.remoteView.layer.borderWidth =1.0;
    self.remoteView.layer.cornerRadius = 8.0;
    
    self.visitFamilyView.clipsToBounds = YES;
    self.visitFamilyView.layer.borderColor = [UIColor colorWithHex:0xfdb731].CGColor;
    self.visitFamilyView.layer.borderWidth =1.0;
    self.visitFamilyView.layer.cornerRadius = 8.0;
    
    self.expatriateView.clipsToBounds = YES;
    self.expatriateView.layer.borderColor = [UIColor colorWithHex:0xfdb731].CGColor;
    self.expatriateView.layer.borderWidth =1.0;
    self.expatriateView.layer.cornerRadius = 8.0;
    
}


#pragma mark - 异地安置登记
- (IBAction)remoteButtonClick:(UIButton *)sender {
    
    DMLog(@"异地安置登记--按钮点击");
    DTFNoticeVC * vc = [[DTFNoticeVC alloc]init];
    vc.type = @"1";
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 探亲登记
- (IBAction)visitFamilyButtonClick:(UIButton *)sender {
    
    DMLog(@"探亲登记--按钮点击");
    DTFNoticeVC * vc = [[DTFNoticeVC alloc]init];
    vc.type = @"2";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 外派人员登记
- (IBAction)expatriateButtonClick:(UIButton *)sender {
    
    DMLog(@"外派人员登记--按钮点击");
    DTFNoticeVC * vc = [[DTFNoticeVC alloc]init];
    vc.type = @"3";
    [self.navigationController pushViewController:vc animated:YES];
}


@end
