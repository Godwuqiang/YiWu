//
//  BannerBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/16.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface BannerBean : BaseDictEntity<NSCoding>

@property(nonatomic, strong) NSString  *title;           // 新闻标题
@property(nonatomic, strong) NSString  *pngurl;          // 图片链接
@property(nonatomic, strong) NSString  *url;             //
@property(nonatomic, strong) NSString  *remarks;

@end
