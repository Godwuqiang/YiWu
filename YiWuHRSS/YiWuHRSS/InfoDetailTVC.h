//
//  InfoDetailTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/12.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoDetailTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Type;
@property (weak, nonatomic) IBOutlet UILabel *Shbzh;
@property (weak, nonatomic) IBOutlet UILabel *Kh;
@property (weak, nonatomic) IBOutlet UILabel *Yhkh;
@property (weak, nonatomic) IBOutlet UILabel *Ydzf;
@property (weak, nonatomic) IBOutlet UILabel *Yhkzf;

@property (weak, nonatomic) IBOutlet UITableViewCell *KhCell;


@end
