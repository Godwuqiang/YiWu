//
//  YLJCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXdyBean.h"

@interface YLJCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ffsj;
@property (weak, nonatomic) IBOutlet UILabel *ffje;

-(void)ConfigCellWithTXdyBean:(TXdyBean*)bean;

@end
