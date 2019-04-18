//
//  RzwtgView.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/6/20.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
//取消按钮点击事件
typedef void(^cancelBlock)();

//确定按钮点击事件
typedef void(^sureBlock)();


@interface RzwtgView : UIView

@property(nonatomic,copy)cancelBlock cancel_block;
@property(nonatomic,copy)sureBlock sure_block;

+(instancetype)alterViewWithContent:(NSString *)content
                             cancel:(NSString *)cancel
                               sure:(NSString *)sure
                      cancelBtClcik:(cancelBlock)cancelBlock
                        sureBtClcik:(sureBlock)sureBlock;

@end
