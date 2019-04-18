//
//  DTFRegistRecordModel.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTFRegistRecordModel : NSObject

@property (nonatomic, strong) NSString *type;       //记录类型
@property (nonatomic, strong) NSString *applyId;    //人员医疗待遇申请ID
@property (nonatomic, strong) NSString *jbsj;       //经办时间
@property (nonatomic, strong) NSString *shzt;       //申办状态
@property (nonatomic, strong) NSString *azdd;       //安置地点
@property (nonatomic, strong) NSString *azyy;       //安置医院
@property (nonatomic, strong) NSString *startTime;  //开始时间
@property (nonatomic, strong) NSString *endTime;    //结束时间
@property (nonatomic, strong) NSString *remark;     //备注



@end
