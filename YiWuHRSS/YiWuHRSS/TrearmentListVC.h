//
//  TrearmentListVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrugBean.h"


@interface TrearmentListVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *keywords;
@property (weak, nonatomic) IBOutlet UIImageView *searchImg;
@property (weak, nonatomic) IBOutlet UITableView *listtableview;
@property (weak, nonatomic) IBOutlet UIImageView *searchBg;


@property (weak, nonatomic) IBOutlet UIView *contentview;
@property (weak, nonatomic) IBOutlet UIImageView *TSbg;
@property (weak, nonatomic) IBOutlet UILabel *TSlb;
@property (weak, nonatomic) IBOutlet UIButton *refreshbtn;

@property (weak, nonatomic) IBOutlet UIView *Coverview;       // 遮盖层

- (IBAction)Search:(id)sender;

@end
