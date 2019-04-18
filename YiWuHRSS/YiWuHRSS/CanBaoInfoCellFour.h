//
//  CanBaoInfoCellFour.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/17.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanBaoInfoBean.h"

@interface CanBaoInfoCellFour : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *BgImg;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UIImageView *IsJF;

-(void)ConfigWithCanBaoInfoBean:(CanBaoInfoBean*)bean;

@end
