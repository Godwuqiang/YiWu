//
//  XBFFWDController.h
//  YiWuHRSS
//
//  Created by MacBook on 2018/5/22.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBFFWDController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *Searchtf;

@property (weak, nonatomic) IBOutlet UIView *bankView; // 银行view

@property (weak, nonatomic) IBOutlet UIView *typeView; // 类型view

@property (weak, nonatomic) IBOutlet UILabel *bankNameLB; // 银行名称

@property (weak, nonatomic) IBOutlet UILabel *typeNameLB; // 银行类型

@property (weak, nonatomic) IBOutlet UITableView *yytableView;

@property (weak, nonatomic) IBOutlet UIView *Tsview;

@property (weak, nonatomic) IBOutlet UIImageView *Tsimg;

@property (weak, nonatomic) IBOutlet UILabel *Tslb;

@property (weak, nonatomic) IBOutlet UIButton *Tsbtn;




@end
