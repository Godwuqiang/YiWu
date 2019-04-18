//
//  DTFRemoteRecordVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  异地安置登记记录详情页-不可编辑

#import <UIKit/UIKit.h>

@class DTFRecordDetailsModel;
@interface DTFRemoteRecordVC : UITableViewController

/** 记录详情 */
@property (nonatomic,strong) DTFRecordDetailsModel * recordDetailsModel;

@end
