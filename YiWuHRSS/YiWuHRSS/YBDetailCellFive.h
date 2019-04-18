//
//  YBDetailCellFive.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYBean.h"

@interface YBDetailCellFive : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *zydate;
@property (weak, nonatomic) IBOutlet UILabel *xyf;
@property (weak, nonatomic) IBOutlet UILabel *cwf;
@property (weak, nonatomic) IBOutlet UILabel *zcf;
@property (weak, nonatomic) IBOutlet UILabel *jyf;
@property (weak, nonatomic) IBOutlet UILabel *zlf;
@property (weak, nonatomic) IBOutlet UILabel *hlf;
@property (weak, nonatomic) IBOutlet UILabel *blzlfy;

-(void)ConfigCellWithZYBean:(ZYBean*)bean;

@end
