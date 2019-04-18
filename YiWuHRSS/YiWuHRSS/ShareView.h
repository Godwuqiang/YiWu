//
//  ShareView.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/9.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

// 取消分享按钮点击事件
typedef void(^cancelBlock)();

// 微信好友按钮点击事件
typedef void(^WechatSessionBlock)();

// 微信朋友圈按钮点击事件
typedef void(^WechatTimeLineBlock)();


@interface ShareView : UIView

@property(nonatomic,copy)   cancelBlock      cancel_block;
@property(nonatomic,copy)WechatSessionBlock  WechatSession_Block;
@property(nonatomic,copy)WechatTimeLineBlock WechatTimeLine_Block;

+(instancetype)shareViewWithTitle:(NSString *)title
                           cancel:(NSString *)cancel
                    cancelBtClcik:(cancelBlock)cancelBlock
                    WechatSessionBtClcik:(WechatSessionBlock)WechatSessionBlock
                    WechatTimeLineBtClcik:(WechatTimeLineBlock)WechatTimeLineBlock;

@end
