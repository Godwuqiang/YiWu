//
//  SMSCodeBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/16.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface SMSCodeBean : BaseDictEntity

@property(nonatomic,strong) NSString        *validCode;     // 短信验证码
@property(nonatomic,strong) NSString        *mobileNo;      // 手机号
@property(nonatomic,strong) NSString        *sendTime;      // 发送时间

@end
