//
//  DTFRegistBaseVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DTFRemoteVC,DTFVisiterFamilyVC,DTFExpatriateVC,DTFRegistModel;

@interface DTFRegistBaseVC : UIViewController

/**
 type: 1:异地安置登记  2:探亲登记  3:外派人员登记
 */
@property (nonatomic ,strong) NSString * type;

@property (strong, nonatomic) DTFRemoteVC * remoteVC;
@property (strong, nonatomic) DTFVisiterFamilyVC * visiteFamilyVC;
@property (strong, nonatomic) DTFExpatriateVC * expatriateVC;


/**
 来自重新提交
 */
@property (assign, nonatomic) BOOL isFromReregist;

/**
 重新提交时带过来的数据模型
 */
@property (nonatomic, strong) DTFRegistModel * registModel;

@end
