//
//  AESCipher.h
//  AESCipher
//
//  Created by Welkin Xie on 8/13/16.
//  Copyright © 2016 WelkinXie. All rights reserved.
//
//  https://github.com/WelkinXie/AESCipher-iOS
//

#import <Foundation/Foundation.h>

#pragma mark - AES加密与解密

/**
 对字符串进行加密,返回加密后的字符串

 @param content 需要进行加密的字符串
 @param key AES加密时的key（在DBNetworkingManager的单例中有初始化）
 @return 加密后的字符串
 */
NSString * aesEncryptString(NSString *content, NSString *key);


/**
 对AES加密后的的字符串进行解密

 @param content 加密后的字符串
 @param key AES加密时的key（在DBNetworkingManager的单例中有初始化）
 @return 解密后的字符串
 */
NSString * aesDecryptString(NSString *content, NSString *key);



/**
 对数据进行加密，返回加密后的数据

 @param data 数据，NSData类型的数据
 @param key AES加密时的key（在DBNetworkingManager的单例中有初始化）
 @return 加密后的数据
 */
NSData * aesEncryptData(NSData *data, NSData *key);



/**
 对数据进行解密，返回解密后的数据

 @param data 需要解密的数据
 @param key AES加密时的key（在DBNetworkingManager的单例中有初始化）
 @return 返回解密后的数据
 */
NSData * aesDecryptData(NSData *data, NSData *key);


#pragma mark - NSData与16进制字符串之间的转换

/**
 将数据转转换为16进制字符串

 @param data 需要转换的数据
 @return 返回转换后的16进制字符串
 */
NSString * dataTohexString(NSData * data);



/**
 将16进制字符串转换为NSData类型

 @param hexString 转换前的16进制字符串
 @return 返回转换后的NSData类型的数据
 */
NSData * hexStringToData(NSString * hexString);
