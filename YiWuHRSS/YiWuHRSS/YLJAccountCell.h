//
//  YLJAccountCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLAccountBean.h"

@interface YLJAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *snzhye;
@property (weak, nonatomic) IBOutlet UILabel *bnsjjfys;
@property (weak, nonatomic) IBOutlet UILabel *dnhzze;
@property (weak, nonatomic) IBOutlet UILabel *dnzhlx;
@property (weak, nonatomic) IBOutlet UILabel *znosjjfys;
@property (weak, nonatomic) IBOutlet UILabel *znmzhljcce;

-(void)ConfigCellWithYLAccountBean:(YLAccountBean*)bean;

@end
