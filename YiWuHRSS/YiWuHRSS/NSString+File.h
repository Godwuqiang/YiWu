//
//  NSString+File.h
//  CoreCategory
//
//  Created by 成林 on 15/4/6.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSString (File)


/*
 *  document根文件夹
 */
+(NSString *)documentFolder;


/*
 *  caches根文件夹
 */
+(NSString *)cachesFolder;




/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)createSubFolder:(NSString *)subFolder;


/**
 *  宽度固定 计算字符串的高度
 *
 *  @param size 字体大小
 *
 *  @return 字符串的高度
 */
- (CGFloat)getHeightBySizeOfFont:(CGFloat)size width:(CGFloat)width;


@end
