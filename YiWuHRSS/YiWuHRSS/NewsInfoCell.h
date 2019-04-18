//
//  NewsInfoCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/12.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsBean.h"

@interface NewsInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *NewsBg;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Pubtime;


@end
