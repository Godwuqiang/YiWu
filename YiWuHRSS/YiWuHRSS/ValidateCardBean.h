//
//  ValidateCardBean.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface ValidateCardBean : BaseDictEntity

@property(nonatomic,strong)NSString     *name;
@property(nonatomic,strong)NSString     *cardType;
@property(nonatomic,strong)NSString     *cardno;
@property(nonatomic,strong)NSString     *shbzh;
@property(nonatomic,strong)NSString     *bank;
@property(nonatomic,strong)NSString     *bankCard;
@property(nonatomic,strong)NSString     *userPng;

@property(nonatomic,strong)NSString     *citCardNum;
@property(nonatomic,strong)NSString     *cardStatus;
@property(nonatomic,strong)NSString     *dzyx;
@property(nonatomic,strong)NSString     *yjdz;
@property(nonatomic,strong)NSString     *bankCode;

@end
