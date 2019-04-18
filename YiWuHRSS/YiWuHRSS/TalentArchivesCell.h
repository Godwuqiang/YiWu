//
//  TalentArchivesCell.h
//  YiWuHRSS
//
//  Created by 大白 on 2019/4/10.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TalentArchivesCell : UITableViewCell

@property (nonatomic,copy)NSString *state;

@property (nonatomic,copy)NSString *arriveTime;

@property (nonatomic,copy)NSString *leaveTime;

+ (instancetype)createCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
