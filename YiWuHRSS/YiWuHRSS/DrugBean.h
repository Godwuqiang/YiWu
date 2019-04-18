//
//  DrugBean.h
//  NingBoHRSS
//
//  Created by 许芳芳 on 16/9/27.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface DrugBean : BaseDictEntity

@property(nonatomic, strong) NSString  *jx;              // 剂型
@property(nonatomic, strong) NSString  *ypmc;            // 药品名称
@property(nonatomic, strong) NSString  *xysm;            // 限用说明
@property(nonatomic, strong) NSString  *gg;              // 规格
@property(nonatomic, strong) NSString  *cj;              // 厂家
@property(nonatomic, strong) NSString  *sbmlbm;          // 编码
@property(nonatomic, strong) NSString  *yibaofenlei;     // 医保分类

@end
