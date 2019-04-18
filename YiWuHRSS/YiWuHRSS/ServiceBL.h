//
//  ServiceBL.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/9.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JiaoFeiInfoBean.h"
#import "YiBaoCostBean.h"
#import "MZBean.h"
#import "ZYBean.h"
#import "TXdyBean.h"
#import "TXdymxBean.h"
#import "YLAccountBean.h"
#import "DDJGBean.h"
#import "DrugBean.h"
#import "ZLBean.h"
#import "YiBaoYeBean.h"
#import "CanBaoInfoBean.h"


@protocol ServiceBLDelegate <NSObject>
@optional
#pragma mark - 参保信息查询回调
-(void)queryCanBaoInfoSucceed:(NSMutableArray *)dictList;
-(void)queryCanBaoInfoFailed:(NSString *)error;

#pragma mark - 五险缴费记录查询
-(void)queryWuXianSucceed:(NSMutableArray *)dictList;
-(void)queryWuXianFailed:(NSString *)error;

#pragma mark - 养老账户查询回调
-(void)queryYLAccountSucceed:(NSMutableArray *)dictList;
-(void)queryYLAccountFailed:(NSString *)error;

#pragma mark - 养老金发放查询回调
-(void)queryYLFFSucceed:(NSMutableArray *)dictList;
-(void)queryYLFFFailed:(NSString *)error;

#pragma mark - 养老金发放明细查询回调
-(void)queryYLMXSucceed:(NSMutableArray *)dictList;
-(void)queryYLMXFailed:(NSString *)error;

#pragma mark - 医保账户余额查询回调
-(void)queryYiBaoYeSucceed:(NSMutableArray *)dictList;
-(void)queryYiBaoYeFailed:(NSString *)error;

#pragma mark - 医保消费记录查询回调
-(void)queryYBCostSucceed:(NSMutableArray *)dictList;
-(void)queryYBCostFailed:(NSString *)error;

#pragma mark - 门诊详情查询回调
-(void)queryMZSucceed:(NSMutableArray *)dictList;
-(void)queryMZFailed:(NSString *)error;

#pragma mark - 住院详情查询回调
-(void)queryZYSucceed:(NSMutableArray *)dictList;
-(void)queryZYFailed:(NSString *)error;

#pragma mark - 两定机构接口回调  定点医院
-(void)queryDingDianJiGouSucceed:(NSMutableArray *)dictList;
-(void)queryDingDianJiGouFailed:(NSString *)error;

#pragma mark - 两定机构接口回调  定点药店
-(void)queryDingDianYaoSucceed:(NSMutableArray *)dictList;
-(void)queryDingDianYaoFailed:(NSString *)error;

#pragma mark - 药品目录接口回调
-(void)queryYaoPinListSucceed:(NSMutableArray *)dictList;
-(void)queryYaoPinListFailed:(NSString *)error;

#pragma mark - 诊疗目录接口回调
-(void)queryZhenLiaoListSucceed:(NSMutableArray *)dictList;
-(void)queryZhenLiaoListFailed:(NSString *)error;

@end

@interface ServiceBL : NSObject

@property (nonatomic,weak) id<ServiceBLDelegate>delegate;

#pragma mark - 管理类的单例
+ (id)sharedManager;

#pragma mark - 参保信息查询
/**
 参保信息查询

 @param shbzh 社会保障号
 @param access_token
 @param TradeCode 交易码
 */
-(void)queryCanBaoInfoWith:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 缴费记录查询
/**
 缴费记录查询

 @param year 年份
 @param shbzh 
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryWuXianWithYear:(NSString*)year andshbzh:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 养老金账户查询
/**
 养老金账户查询

 @param year 年份
 @param shbzh 社会保障号
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryYLAccountWithYear:(NSString*)year andshbzh:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 养老金发放查询
/**
 养老金发放查询

 @param shbzh 社会保障号
 @param pageNo 页数
 @param pageSize 每页数量
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryYLFFWith:(NSString*)shbzh andpageNo:(int)pageNo andpageSize:(int)pageSize andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 养老金发放明细查询
/**
 养老金发放明细查询

 @param shbzh 社会保障号
 @param month 月份
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryYLMXWith:(NSString*)shbzh andmonth:(NSString*)month andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 医保账户余额查询
/**
 医保账户余额查询

 @param shbzh 社会保障号
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryYiBaoYeWith:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 医保消费记录查询
/**
 医保消费记录查询

 @param shbzh 社会保障号
 @param year 年份
 @param pageNo 页数
 @param pageSize 每页数量
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryYBCostListWith:(NSString*)shbzh andyear:(NSString*)year andpageNo:(int)pageNo andpageSize:(int)pageSize andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 门诊详情查询
/**
 门诊详情查询

 @param xfCode 医保消费code
 @param xfType 医保消费类型
 @param access_token token
 @param TradeCode 交易码
 */
-(void)queryMZWith:(NSString*)xfCode andxfType:(NSString*)xfType andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode;

#pragma mark - 住院详情查询
/**
 住院详情查询

 @param xfCode 医保消费code
 @param xfType 医保消费类型
 @param access_token token
 @param TradeCode 交易码
 @param jscxh 住院详情类型
 */
-(void)queryZYWith:(NSString*)xfCode andxfType:(NSString*)xfType andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode andJSCXH:(NSString*)jscxh;

#pragma mark - 两定机构查询  定点医院
/**
 定点医院

 @param ddyljgmc 定点医疗机构名称
 @param type 类型
 @param pageNo 页数
 @param pageSize 每页数量
 @param TradeCode 交易码
 */
-(void)queryDingDianJiGouWith:(NSString*)ddyljgmc andtype:(NSString*)type andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode;

#pragma mark - 两定机构查询  定点药店
/**
 定点药店

 @param ddyljgmc 定点医疗机构名称
 @param type 类型
 @param pageNo 页数
 @param pageSize 每页数量
 @param TradeCode 交易码
 */
-(void)queryDingDianYaoWith:(NSString*)ddyljgmc andtype:(NSString*)type andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode;

#pragma mark - 药品目录查询
/**
 药品目录查询

 @param mlmc 目录名称
 @param pageNo 页数
 @param pageSize 每页数量
 @param TradeCode 交易码
 */
-(void)queryYaoPinListWith:(NSString*)mlmc andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode;

#pragma mark - 诊疗目录查询
/**
 诊疗目录查询

 @param zlmlmc 诊疗目录名称
 @param pageNo 页数
 @param pageSize 每页数量
 @param TradeCode 交易码
 */
-(void)queryZhenLiaoListWith:(NSString*)zlmlmc andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode;

@end
