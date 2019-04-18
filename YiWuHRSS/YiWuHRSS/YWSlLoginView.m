//
//  YWSlLoginView.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWSlLoginView.h"

@implementation YWSlLoginView

/**
 创建刷脸登录的View
 
 @return 密码登录的View
 */
+(instancetype)slLoginView{
    return [[NSBundle mainBundle] loadNibNamed:@"YWSlLoginView" owner:self options:nil].firstObject;
}




@end
