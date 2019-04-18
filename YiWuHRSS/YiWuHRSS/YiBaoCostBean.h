//
//  YiBaoCostBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface YiBaoCostBean : BaseDictEntity

@property(nonatomic,strong) NSString        *ybxfdh;       // 医保消费单号
@property(nonatomic,strong) NSString        *ybxfsj;       // 医保消费时间
@property(nonatomic,strong) NSString        *ybxfdd;       // 医保消费地点
@property(nonatomic,strong) NSString        *ybxfje;       // 医保消费金额
@property(nonatomic,strong) NSString        *ybxflx;       // 医保消费类型
@property(nonatomic,strong) NSString        *jscxh;        // 结算次序号


@end
