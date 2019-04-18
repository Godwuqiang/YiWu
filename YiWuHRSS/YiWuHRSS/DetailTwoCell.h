//
//  DetailTwoCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/12.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTwoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Netname;
@property (weak, nonatomic) IBOutlet UILabel *zk;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *tel;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@end
