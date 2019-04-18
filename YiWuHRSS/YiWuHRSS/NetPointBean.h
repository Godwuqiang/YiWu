//
//  NetPointBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/11.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface NetPointBean : BaseDictEntity

@property(nonatomic,strong) NSString        *id;             // 定点医疗机构名称
@property(nonatomic,strong) NSString        *branchnmae;     // 网点名称
@property(nonatomic,strong) NSString        *address;        // 网点地址
@property(nonatomic,strong) NSString        *tel;            // 联系电话
@property(nonatomic,strong) NSString        *creattime;      // 创建时间
@property(nonatomic,strong) NSString        *jianjie;        // 简介
@property(nonatomic,strong) NSString        *bankMark;       // 银行代码
@property(nonatomic,strong) NSString        *ismaked;        // 可制卡标志
@property(nonatomic,strong) NSString        *isResetPassword;// 0：不可密码重置 1：可重密码置
@property(nonatomic,strong) NSString        *jingdu;         // 经度
@property(nonatomic,strong) NSString        *weidu;          // 纬度
@property(nonatomic,strong) NSString        *distance;       // 距离

@end
