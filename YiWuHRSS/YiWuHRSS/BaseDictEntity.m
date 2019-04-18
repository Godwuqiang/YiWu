//
//  BaseDictEntity.m
//  NingBoHRSS
//
//  Created by 许芳芳 on 16/9/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@implementation BaseDictEntity

- (instancetype)initWithDict:(NSMutableDictionary *)dict
{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}


+(instancetype)entityWithDict:(NSMutableDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

@end
