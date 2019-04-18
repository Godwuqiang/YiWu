//
//  MineCellOne.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/29.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineCellOne : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myphoto;
@property (weak, nonatomic) IBOutlet UIView *ViewLoad;
@property (weak, nonatomic) IBOutlet UIView *ViewUnLoad;
@property (weak, nonatomic) IBOutlet UIView *ViewHX;


@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *authenImg;
@property (weak, nonatomic) IBOutlet UILabel *shbzh;
@property (weak, nonatomic) IBOutlet UILabel *kahao;
@property (weak, nonatomic) IBOutlet UILabel *bank;
@property (weak, nonatomic) IBOutlet UILabel *bankcardnum;
@property (weak, nonatomic) IBOutlet UILabel *isydzf;
@property (weak, nonatomic) IBOutlet UILabel *isbankzf;
@property (weak, nonatomic) IBOutlet UIButton *msgBtn;


@property (weak, nonatomic) IBOutlet UILabel *hxname;
@property (weak, nonatomic) IBOutlet UIImageView *hxauthen;
@property (weak, nonatomic) IBOutlet UILabel *hxshbzh;
@property (weak, nonatomic) IBOutlet UILabel *hxbank;
@property (weak, nonatomic) IBOutlet UILabel *hxbanknum;
@property (weak, nonatomic) IBOutlet UILabel *hxybydzf;
@property (weak, nonatomic) IBOutlet UILabel *hxyhkzf;
@property (weak, nonatomic) IBOutlet UIButton *hxmsgBtn;



@end
