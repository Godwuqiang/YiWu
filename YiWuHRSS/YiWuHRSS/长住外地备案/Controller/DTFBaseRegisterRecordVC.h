//
//  DTFBaseRegisterRecordVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFBaseRegisterRecordVC : UIViewController

/**
 type: 1:异地安置登记  2:探亲登记  3:外派人员登记
 */
@property (nonatomic ,strong) NSString * type;


/**
 人员医疗待遇申请ID
 */
@property (nonatomic ,strong) NSString * apply_id;


/** 审核状态 */
@property (nonatomic,strong) NSString * shzt;
/** 审核状态描述 */
@property (nonatomic,strong) NSString * remark;


@end
