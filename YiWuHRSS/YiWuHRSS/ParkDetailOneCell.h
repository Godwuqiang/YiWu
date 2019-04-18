//
//  ParkDetailOneCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkBean.h"

@interface ParkDetailOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *Img;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Address;
@property (weak, nonatomic) IBOutlet UILabel *Kynum;
@property (weak, nonatomic) IBOutlet UILabel *Zsnum;
@property (weak, nonatomic) IBOutlet UILabel *Kylb;

@property (weak, nonatomic) IBOutlet UIImageView *Icon1;
@property (weak, nonatomic) IBOutlet UIImageView *Icon2;
@property (weak, nonatomic) IBOutlet UIImageView *Icon3;
@property (weak, nonatomic) IBOutlet UIView *Line;



@property (nonatomic, strong) ParkBean *parkbean;

@end
