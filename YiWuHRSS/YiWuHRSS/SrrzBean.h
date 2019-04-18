//
//  SrrzBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/23.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface SrrzBean : BaseDictEntity

@property(nonatomic,strong) NSString        *hospMobpay;      // 医保移动支付开通状态  1：已开通  0：未开通
@property(nonatomic,strong) NSString        *renzhengStatus;  // 认证结果 1.认证成功(上传图片) 2.申请中(银行验证未上传图片) 3.审核中  4.审核未通过(认证撤销)
@property(nonatomic,strong) NSString        *blackFlag;    // 是否是黑名单 1.是
@property(nonatomic,strong) NSString        *rzMsg;        // 认证返回信息

@end
