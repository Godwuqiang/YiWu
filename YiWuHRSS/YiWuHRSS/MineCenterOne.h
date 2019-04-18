//
//  MineCenterOne.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/10.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineCenterOne : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mybgImg;
@property (weak, nonatomic) IBOutlet UIImageView *titImg;
@property (weak, nonatomic) IBOutlet UILabel *titlb;
@property (weak, nonatomic) IBOutlet UIButton *msgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *msgdot;
@property (weak, nonatomic) IBOutlet UILabel *msgnum;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numrightconstrains; // 10以内(19) 10以上(16)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numtopconstrains;  //  显示数字(3)  显示...(0)


@property (weak, nonatomic) IBOutlet UILabel *environmentLabel;


@property (weak, nonatomic) IBOutlet UIView *ViewUnload;


@property (weak, nonatomic) IBOutlet UIView *ViewLoad;
@property (weak, nonatomic) IBOutlet UIImageView *loadImg;
@property (weak, nonatomic) IBOutlet UIImageView *loadtouxiang;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *authenImg;
@property (weak, nonatomic) IBOutlet UIImageView *shbzhImg;
@property (weak, nonatomic) IBOutlet UILabel *shbzhlb;
@property (weak, nonatomic) IBOutlet UILabel *shbzh;
@property (weak, nonatomic) IBOutlet UIImageView *khImg;
@property (weak, nonatomic) IBOutlet UILabel *khlb;
@property (weak, nonatomic) IBOutlet UILabel *kh;

@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UILabel *identifyLabel;


@end
