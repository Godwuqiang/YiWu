//
//  DTFPrivateMessageBean.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTFPrivateMessageBean : NSObject


@property (nonatomic ,assign) BOOL isFoldMessage;//是否是折叠的消息
@property (nonatomic ,assign) BOOL isSelectedMessage;//是否是选中操作的Cell
@property (nonatomic ,assign) BOOL isCellDeleteViewShow;//cell中的删除按钮是否显示出来
@property (nonatomic ,assign) BOOL isFoldButtonHidden;//cell中的折叠按钮是否隐藏


@property (nonatomic ,strong) NSString * msgTime;
@property (nonatomic ,strong) NSString * msgTitle;
@property (nonatomic ,strong) NSString * msgContent;

@property (nonatomic ,strong) NSString * content;
@property (nonatomic ,strong) NSString * msgId;
@property (nonatomic ,strong) NSString * readStatus;
@property (nonatomic ,strong) NSString * serviceType;
@property (nonatomic ,strong) NSString * summary;
@property (nonatomic ,strong) NSString * title;
@property (nonatomic ,strong) NSString * type;
@property (nonatomic ,strong) NSString * update_time;
@property (nonatomic ,strong) NSString * url;
@property (nonatomic ,strong) NSString * userId;



@end
