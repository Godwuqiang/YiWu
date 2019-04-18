//
//  Base64.h
//  NingBoHRSS
//
//  Created by 大白开发电脑 on 16/12/28.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+(NSString *)encode:(NSData *)data;
+(NSData *)decode:(NSString *)dataString;


@end
