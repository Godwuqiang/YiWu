//
//  YBDetailCellFour.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZBean.h"
#import "ZYBean.h"

@interface YBDetailCellFour : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *total;
@property (weak, nonatomic) IBOutlet UILabel *baoxiao;
@property (weak, nonatomic) IBOutlet UILabel *zhifu;

-(void)ConfigCellFourWithMZBean:(MZBean*)bean;

-(void)ConfigCellFourWithZYBean:(ZYBean*)bean;

@end
