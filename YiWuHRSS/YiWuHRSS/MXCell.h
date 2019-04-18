//
//  MXCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXdymxBean.h"


@interface MXCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *xz;
@property (weak, nonatomic) IBOutlet UILabel *ffyh;
@property (weak, nonatomic) IBOutlet UILabel *yhzh;
@property (weak, nonatomic) IBOutlet UILabel *je;

-(void)ConfigCellWithTXdymxBean:(TXdymxBean*)bean;

@end
