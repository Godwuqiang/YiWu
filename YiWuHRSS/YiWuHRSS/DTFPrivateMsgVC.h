//
//  DTFPrivateMsgVC.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DTFPrivateMessageBean;


@interface DTFPrivateMsgVC : UITableViewController

@property (nonatomic ,assign)       BOOL            isDeleteButtonShow;             // 是否已经有出现删除按钮
@property (nonatomic ,strong)       UIImageView     * bgImageView;                  // 是否已经有出现删除按钮
@property (nonatomic, strong)       DTFPrivateMessageBean        * deleteSingleMsg; //要被单个删除的消息

@property (nonatomic, strong)       NSString        *type;

@end
