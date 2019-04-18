//
//  DTFQualificationConfirmVC.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFQualificationConfirmVC : UIViewController

/** 姓名 */
@property (nonatomic ,strong) NSString * name;
/** 生存认证流水号 */
@property (nonatomic ,strong) NSString * serialNumber;
/** 社会保障号 */
@property (nonatomic ,strong) NSString * shbzh;


/** 是否来自其他社保待遇资格认证列表 */
@property (nonatomic ,assign) BOOL isFromOtherQualiferList;
/** 其他社保待遇资格认证ID */
@property (nonatomic ,assign) NSInteger ID;


@end
