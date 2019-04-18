//
//  DTFRecordDetailsModel.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/7.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTFRecordDetailsModel : NSObject


@property (nonatomic,strong) NSString * name;               //联系人姓名
@property (nonatomic,strong) NSString * mobile;             //联系方式
@property (nonatomic,strong) NSString * azdz;               //安置地点
@property (nonatomic,strong) NSString * jtdz;               //具体地址
@property (nonatomic,strong) NSString * ydazyy;             //异地安置原因
@property (nonatomic,strong) NSString * shzt;               //审核状态
@property (nonatomic,strong) NSArray<NSString *> * azyy;    //安置医院
@property (nonatomic,strong) NSString * azdzbm;             //安置地址编码
@property (nonatomic,strong) NSString * djbhqfs;            //登记表获取方式
@property (nonatomic,strong) NSString * documentPic;        //证件图片
@property (nonatomic,strong) NSString * remark;             //备注
@property (nonatomic,strong) NSString * startTime;          //开始时间
@property (nonatomic,strong) NSString * endTime;            //结束时间



@end
