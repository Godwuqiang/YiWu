//
//  TreatmentDetailTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/12/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLBean.h"


@interface TreatmentDetailTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *zlmlmc;
@property (weak, nonatomic) IBOutlet UILabel *ybfl;
@property (weak, nonatomic) IBOutlet UILabel *bm;
@property (weak, nonatomic) IBOutlet UILabel *bz;

@property (nonatomic, strong) ZLBean  *bean;

@end
