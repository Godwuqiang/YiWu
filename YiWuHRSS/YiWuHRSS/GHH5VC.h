//
//  GHH5VC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
//#import "UIWebView+TS_JavaScriptContext.h"
//
//@protocol JS_GHViewController <JSExport>
//
//- (void)linkSdkIdCode;  //切换参保人时传给app端方法
//
//- (void)linkBankOpen; 
//
//- (void)getToken;
//
//- (void)statusQuery;
//
//- (void)backRoot;
//
//-(void)backToTab;
//
//@end

@interface GHH5VC : UIViewController

//@property (weak, nonatomic) IBOutlet UIWebView *ghwebview;

#pragma mark - SH512加密函数
-(void)SHSign:(NSString*)str;

@end
