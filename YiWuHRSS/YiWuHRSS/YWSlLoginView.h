//
//  YWSlLoginView.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWSlLoginView : UIView

@property (weak, nonatomic) IBOutlet UIView *identifyView;
@property (weak, nonatomic) IBOutlet UITextField *identifyTextField;

/**
 创建刷脸登录的View
 
 @return 刷脸登录的View
 */
+(instancetype)slLoginView;

@end
