//
//  DTFRegistModel.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/7.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  登记时传的数据模型

#import <Foundation/Foundation.h>

@interface DTFRegistModel : NSObject

/** 业务类型:01异地就医;02探亲出差;03外派登记 */
@property (nonatomic,strong) NSString * type;
/** 联系人姓名 */
@property (nonatomic,strong) NSString * contact_name;
/** 联系人联系方式 */
@property (nonatomic,strong) NSString * contact_mobile;
/** 省编码 */
@property (nonatomic,strong) NSString * provice_code;
/** 市编码 */
@property (nonatomic,strong) NSString * city_code;
/** 区县编码 */
@property (nonatomic,strong) NSString * country_code;
/** 具体地址 */
@property (nonatomic,strong) NSString * address;
/** 安置原因 011回原籍居住；012户籍异地落户居住；013随直系亲属异地居住；021探亲；022出差 */
@property (nonatomic,strong) NSString * reason;
/** 登记表获取方式 1自取；2邮寄； */
@property (nonatomic,strong) NSString * djbhqfs;
/** 开始时间 */
@property (nonatomic,strong) NSString * start_time;
/** 结束时间 */
@property (nonatomic,strong) NSString * end_time;
/** 医院ID或者医院名称 中间用^隔开 */
@property (nonatomic,strong) NSString * hospital_id;
/** 证件照片 */
@property (nonatomic,strong) NSString * document_image;

/** 安置地点 */
@property (nonatomic,strong) NSString * azdz;


@end
