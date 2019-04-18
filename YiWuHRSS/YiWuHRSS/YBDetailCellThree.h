//
//  YBDetailCellThree.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZBean.h"

@interface YBDetailCellThree : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *BgImg;
@property (weak, nonatomic) IBOutlet UILabel *ypmc;
@property (weak, nonatomic) IBOutlet UILabel *cost;

-(void)ConfigCellThreeWithMZBean:(MZBean*)bean;

@end
