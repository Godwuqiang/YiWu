//
//  NetPointCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/2/20.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetPointCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Address;
@property (weak, nonatomic) IBOutlet UILabel *Type;
@property (weak, nonatomic) IBOutlet UILabel *Type2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *type2RightConstraint;



@property (weak, nonatomic) IBOutlet UIImageView *addImg;
@property (weak, nonatomic) IBOutlet UILabel *Jl;





@end
