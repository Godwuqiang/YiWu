//
//  YBDetailCellOne.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZBean.h"
#import "ZYBean.h"


@interface YBDetailCellOne : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rylb;
@property (weak, nonatomic) IBOutlet UILabel *dd;
@property (weak, nonatomic) IBOutlet UILabel *lx;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *jbms;

-(void)ConfigCellOneWithMZBean:(MZBean*)bean;

-(void)ConfigCellOneWithZYBean:(ZYBean*)bean;

@end
