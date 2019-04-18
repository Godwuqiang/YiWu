//
//  ChangeCardBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/6/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface ChangeCardBean : BaseDictEntity

@property(nonatomic,strong) NSString        *cardType;       // 实人认证系统返回的卡类型
@property(nonatomic,strong) NSString        *sourceUserId;   // 实人认证系统返回的卡类型
@property(nonatomic,strong) NSString        *oldCardNum;     // 修改前社会保障号
@property(nonatomic,strong) NSString        *oldSiCard;      // 修改前卡号
@property(nonatomic,strong) NSString        *oldIdCard;      // 修改前身份证号
@property(nonatomic,strong) NSString        *oldIdCode;      // 修改前卡内识别码
@property(nonatomic,strong) NSString        *userName;       // 修改后用户姓名
@property(nonatomic,strong) NSString        *mobile;         // 修改后手机号
@property(nonatomic,strong) NSString        *idCard;         // 修改后身份证号
@property(nonatomic,strong) NSString        *cardNum;        // 修改后社会保障号
@property(nonatomic,strong) NSString        *siCard;         // 修改后卡号
@property(nonatomic,strong) NSString        *idCode;         // 修改后卡内识别码
@property(nonatomic,strong) NSString        *bankNum;        // 修改后银行卡号
@property(nonatomic,strong) NSString        *bankCode;       // 修改后银行编号
@property(nonatomic,strong) NSString        *flag;           // 市民卡类型
@property(nonatomic,strong) NSString        *exp;            // exp 是"yyyyMMddHHmmss" 格式的 Date
@property(nonatomic,strong) NSString        *sign;           // 加密的参数
@property(nonatomic,strong) NSString        *source;         // 参数

@end
