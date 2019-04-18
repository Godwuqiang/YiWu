//
//  PayCellTwo.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/19.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JiaoFeiInfoBean.h"


@interface PayCellTwo : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *BgImg;
@property (weak, nonatomic) IBOutlet UIImageView *IsDZ;
@property (weak, nonatomic) IBOutlet UILabel *bxmc;
@property (weak, nonatomic) IBOutlet UILabel *jfjs;
@property (weak, nonatomic) IBOutlet UILabel *dwjf;
@property (weak, nonatomic) IBOutlet UILabel *grjf;
@property (weak, nonatomic) IBOutlet UILabel *company;

-(void)ConfigCellWithJiaoFeiInfoBean:(JiaoFeiInfoBean*)bean;

@end
