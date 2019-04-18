//
//  NewsBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface NewsBean : BaseDictEntity

@property(nonatomic, strong) NSString  *id;              //
@property(nonatomic, strong) NSString  *title;           // 新闻标题
@property(nonatomic, strong) NSString  *pngurl;          // 图片链接
@property(nonatomic, strong) NSString  *subtime;         // 发布时间
@property(nonatomic, strong) NSString  *subState;        // 发布状态
@property(nonatomic, strong) NSString  *newsType;        // 新闻类型

@end
