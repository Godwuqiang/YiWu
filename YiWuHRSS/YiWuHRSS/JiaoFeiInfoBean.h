//
//  JiaoFeiInfoBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface JiaoFeiInfoBean : BaseDictEntity

@property(nonatomic,strong) NSString        *xzbm;         // 险种编码
@property(nonatomic,strong) NSString        *xzmc;         // 险种名称
@property(nonatomic,strong) NSString        *jfsj;         // 缴费时间
@property(nonatomic,strong) NSString        *dwjf;         // 单位缴费
@property(nonatomic,strong) NSString        *grjf;         // 个人缴费

@property(nonatomic,strong) NSString        *jfze;         // 缴费总额
@property(nonatomic,strong) NSString        *jfjs;         // 缴费基数
@property(nonatomic,strong) NSString        *jfdw;         // 缴费单位
@property(nonatomic,strong) NSString        *jfStatus;     // 缴费状态

@end
