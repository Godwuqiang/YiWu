//
//  ZLBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/9.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface ZLBean : BaseDictEntity

@property(nonatomic, strong) NSString  *jsxmmc;          // 接受项目mc
@property(nonatomic, strong) NSString  *zlxmmc;          // 诊疗项目名称
@property(nonatomic, strong) NSString  *ybfl;            // 医保分类
@property(nonatomic, strong) NSString  *sbmlbm;          // 编码
@property(nonatomic, strong) NSString  *beizhu;          // 备注

@end
