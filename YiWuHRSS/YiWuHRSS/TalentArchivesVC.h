//
//  TalentArchivesVC.h
//  YiWuHRSS
//
//  Created by 大白 on 2019/4/9.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TalentArchivesVC : UIViewController
{
    UIImageView  *bgImg;
    UIImageView  *headurl;
    UILabel      *namelb;
    UILabel      *cardlb;

    UITableView  *cbinfotableview;
    TSView       *tsview;
}


@end

NS_ASSUME_NONNULL_END
