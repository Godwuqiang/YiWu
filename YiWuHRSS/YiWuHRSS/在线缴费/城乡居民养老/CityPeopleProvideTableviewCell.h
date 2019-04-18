//
//  CityPeopleProvideTableviewCell.h
//  YiWuHRSS
//
//  Created by 大白 on 2019/3/6.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CityPeopleProvideTableviewCell : UITableViewCell

@property (nonatomic,copy)NSString *name;

@property (nonatomic,copy)NSString *value;

@property (nonatomic,strong)id information;//记录特殊的信息

@property (nonatomic,strong)UIImageView *directionImage;//右边的箭头 默认隐藏

@end

NS_ASSUME_NONNULL_END
