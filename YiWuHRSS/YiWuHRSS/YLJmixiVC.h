//
//  YLJmixiVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface YLJmixiVC : UIViewController
{
    UIImageView  *headurl;
    UILabel      *namelb;
    UILabel      *cardlb;
    
    UITableView  *ylmxjinfotableview;
}

@property (nonatomic, strong) NSString *time;

@end
