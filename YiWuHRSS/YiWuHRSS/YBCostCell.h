//
//  YBCostCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YiBaoCostBean.h"


@interface YBCostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *BgImg;
@property (weak, nonatomic) IBOutlet UILabel *Time;
@property (weak, nonatomic) IBOutlet UILabel *Cost;
@property (weak, nonatomic) IBOutlet UILabel *Hospital;
@property (weak, nonatomic) IBOutlet UIImageView *type;

-(void)ConfigCellWithYiBaoCostBean:(YiBaoCostBean*)bean;

@end
