//
//  UserBean.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDictEntity.h"

@interface UserBean : BaseDictEntity

@property(nonatomic,strong) NSString        *id;
@property(nonatomic,strong) NSString        *name;
@property(nonatomic,strong) NSString        *password;
@property(nonatomic,strong) NSString        *cardType;
@property(nonatomic,strong) NSString        *cardno;
@property(nonatomic,strong) NSString        *shbzh;
@property(nonatomic,strong) NSString        *bank;
@property(nonatomic,strong) NSString        *bankCard;
@property(nonatomic,strong) NSString        *isHaveCard;
@property(nonatomic,strong) NSString        *userPng;
@property(nonatomic,strong) NSString        *cardMobile;
@property(nonatomic,strong) NSString        *bankMobile;
@property(nonatomic,strong) NSString        *appMobile;
@property(nonatomic,strong) NSString        *cardStatus;
@property(nonatomic,strong) NSString        *dzyx;
@property(nonatomic,strong) NSString        *yjdz;
@property(nonatomic,strong) NSString        *updateTime;
@property(nonatomic,strong) NSString        *createTime;
@property(nonatomic,strong) NSString        *loginTime;
@property(nonatomic,strong) NSString        *access_token;

@property(nonatomic,strong) NSString        *citCardNum;
@property(nonatomic,strong) NSString        *bankCode;
@property(nonatomic,strong) NSString        *ydzf_status;
@property(nonatomic,strong) NSString        *srrz_status;
@property(nonatomic,strong) NSString        *bankzf_status;

@property(nonatomic,strong) NSString        *imei;
@property(nonatomic,strong) NSString        *failureNum;
@property(nonatomic,strong) NSString        *lockFlag;
@property(nonatomic,strong) NSString        *loginGqtime;

@property(nonatomic,strong) NSString        *birthDate;
@property(nonatomic,strong) NSString        *gender;
@property(nonatomic,strong) NSString        *push_alias;   // 极光推送别名

@property(nonatomic,strong) NSString        *setPassword; //是否设置过支付密码

@end
