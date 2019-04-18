//
//  DTFRegisterRecordVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFRegisterRecordVC : UITableViewController


/**
 类型：1.异地安置登记记录  2.探亲登记记录  3.外派人员登记记录
 */
@property (nonatomic, strong) NSString * type;

@end
