//
//  ModifyCardView.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/29.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

//确定按钮点击事件
typedef void(^sureBlock)();

@interface ModifyCardView : UIView

@property(nonatomic,copy)sureBlock sure_block;

+(instancetype)alterViewWithcontent:(NSString *)content
                               sure:(NSString *)sure
                        sureBtClcik:(sureBlock)sureBlock;


@end
