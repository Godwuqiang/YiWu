//
//  AESData.h
//  ParameterEncyptSDK
//
//  Created by 于良建 on 2017/10/24.
//  Copyright © 2017年 liuxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESData : NSObject

+ (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv data:(NSData *)aesData;   //加密
+ (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv data:(NSData *)aesData;   //解密

@end
