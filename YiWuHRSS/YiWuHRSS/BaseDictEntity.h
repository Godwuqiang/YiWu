//
//  BaseDictEntity.h
//  NingBoHRSS
//
//  Created by 许芳芳 on 16/9/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDictEntity : NSObject

#pragma mark 从字典对象转为自身模型对象
+ (instancetype)entityWithDict:(NSDictionary *)dict;

#pragma mark 类方法：从字典对象转为模型对象
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
