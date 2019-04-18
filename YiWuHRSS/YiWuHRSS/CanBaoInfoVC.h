//
//  CanBaoInfoVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/19.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSView.h"

@interface CanBaoInfoVC : UIViewController
{
    UIImageView  *bgImg;
    UIImageView  *headurl;
    UILabel      *namelb;
    UILabel      *cardlb;
    
    UITableView  *cbinfotableview;
    TSView       *tsview;
}


@end
