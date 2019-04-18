//
//  NoticeBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface NoticeBean : BaseDictEntity

@property(nonatomic,strong) NSString        *is_details;        // 是否跳转详情页
@property(nonatomic,strong) NSString        *content;           // 公告内容
@property(nonatomic,strong) NSString        *begintime;
@property(nonatomic,strong) NSString        *endtime;

@end
