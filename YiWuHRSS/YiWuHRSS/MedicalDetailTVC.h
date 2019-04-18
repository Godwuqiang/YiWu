//
//  MedicalDetailTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/12/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrugBean.h"

@interface MedicalDetailTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *YPMCCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *XYSMCell;

@property (weak, nonatomic) IBOutlet UILabel *ypmc;
@property (weak, nonatomic) IBOutlet UILabel *jx;
@property (weak, nonatomic) IBOutlet UILabel *ybfl;
@property (weak, nonatomic) IBOutlet UILabel *xysm;
@property (weak, nonatomic) IBOutlet UILabel *bm;
@property (weak, nonatomic) IBOutlet UILabel *gg;
@property (weak, nonatomic) IBOutlet UILabel *cj;

@property(nonatomic, strong)  DrugBean    *bean;

@end
