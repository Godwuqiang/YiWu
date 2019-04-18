//
//  CanBaoInfoCellTwo.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/17.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanBaoInfoCellTwo : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *xb;
@property (weak, nonatomic) IBOutlet UILabel *birth;
@property (weak, nonatomic) IBOutlet UILabel *idnum;

-(void)ConfigCell;

@end
