//
//  MsgBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/4/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface MsgBean : BaseDictEntity

@property(nonatomic,strong) NSString        *id;
@property(nonatomic,strong) NSString        *title;
@property(nonatomic,strong) NSString        *url;
@property(nonatomic,strong) NSString        *content;
@property(nonatomic,strong) NSString        *type;     //Type 为 1 表示消息有跳转链接型消息 Type 为 2 表示为纯文本型消息 1 和 2 有且只有一个
@property(nonatomic,strong) NSString        *update_time;
@property(nonatomic,strong) NSString        *sendTime;
@property(nonatomic,strong) NSString        *msgTitle;

@property(nonatomic,strong) NSString        *msgId;   // 消息ID
@property(nonatomic,strong) NSString        *serviceType; // 服务类型
@property(nonatomic,strong) NSString        *summary;  // 消息摘要
@property(nonatomic,strong) NSString        *readStatus; // 已读状态
@property(nonatomic,strong) NSString        *userId;   // 用户ID

@property(nonatomic,strong) NSString        *ischoosed; // 是否被选中

@end
