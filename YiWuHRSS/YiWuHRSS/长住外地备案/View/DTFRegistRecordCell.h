//
//  DTFRegistRecordCell.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTFRegistRecordModel;

@interface DTFRegistRecordCell : UITableViewCell

/** 登记记录数据模型 */
@property (nonatomic,strong) DTFRegistRecordModel * recordModel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;

@end
