//
//  NewsDetailVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsBean.h"

@interface NewsDetailVC : UIViewController

@property (nonatomic, strong)  NSString  *ID;
@property (nonatomic, strong)  NewsBean  *news;

@end
