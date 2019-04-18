//
//  ContextDetailVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/6/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgBean.h"

@interface ContextDetailVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Time;
@property (weak, nonatomic) IBOutlet UILabel *Context;

@property (nonatomic, strong)  MsgBean  *bean;
@property (nonatomic, strong)  NSString *LX;

@end
