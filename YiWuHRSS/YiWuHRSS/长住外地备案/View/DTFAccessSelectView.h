//
//  DTFAccessSelectView.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectedType)(NSString *type);

@interface DTFAccessSelectView : UIView

@property (nonatomic, copy) selectedType selectedType;

/**
 登记表获取方式 1自取；2邮寄；
 */
@property (nonatomic, strong) NSString *djbhqfs;

@end
