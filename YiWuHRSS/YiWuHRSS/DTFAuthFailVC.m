//
//  DTFAuthFailVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/10/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFAuthFailVC.h"

@interface DTFAuthFailVC ()

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;


@end

@implementation DTFAuthFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"实人认证";
    _tipsLabel.textAlignment = NSTextAlignmentRight;
    _tipsLabel.textColor = [UIColor colorWithHex:999999];
    _tipsLabel.font = [UIFont systemFontOfSize:12.0];
    _tipsLabel.text = [NSString stringWithFormat:@"您当天还剩%li次认证机会，请重新认证！",self.lastSrrzCount];
    
    NSMutableAttributedString *attribtedS = [[NSMutableAttributedString alloc] initWithAttributedString:_tipsLabel.attributedText];
    [attribtedS addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 1)];
    [_tipsLabel setAttributedText:attribtedS];
}




/**
 重新认证按钮点击事件

 @param sender 重新认证按钮
 */
- (IBAction)reAuthButtonClick:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
