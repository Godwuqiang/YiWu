//
//  ParkCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkBean.h"

@interface ParkCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *Img;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Address;
@property (weak, nonatomic) IBOutlet UIImageView *Imgjuli;
@property (weak, nonatomic) IBOutlet UILabel *Juli;

@property (nonatomic, strong) ParkBean *parkbean;

@end
