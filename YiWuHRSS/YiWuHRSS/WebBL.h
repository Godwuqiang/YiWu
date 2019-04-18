//
//  WebBL.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetPointBean.h"
#import "UserBean.h"
#import "ParkBean.h"


@protocol WebBLDelegate <NSObject>
@optional

#pragma mark - 上传图片接口回调
-(void)UpdatePictureSucceed:(NSString *)message;
-(void)UpdatePictureFailed:(NSString *)error;

#pragma mark - 服务网点接口回调
-(void)queryNetWorkPointSucceed:(NSMutableArray*)dictList;
-(void)queryNetWorkPointFailed:(NSString*)error;

#pragma mark - 修改登录密码接口回调
-(void)ChangLoginPsdSucceed:(NSString*)message;
-(void)ChangLoginPsdFailed:(NSString*)error;

#pragma mark - 获取用户家庭住址接口回调
-(void)queryHomeAddressSucceed:(UserBean *)bean;
-(void)queryHomeAddressFailed:(NSString*)error;

#pragma mark - 添加/修改用户家庭住址接口回调
-(void)ChangHomeAddressSucceed:(NSString*)message;
-(void)ChangHomeAddressFailed:(NSString*)error;

#pragma mark - 获取公共汽车停车位信息接口回调
-(void)queryPublicParksSucceed:(NSMutableArray*)dictList;
-(void)queryPublicParksFailed:(NSString*)error;

#pragma mark - 获取公共汽车停车位单个信息接口回调
-(void)queryParkInfoSucceed:(ParkBean *)bean;
-(void)queryParkInfoFailed:(NSString*)error;

@end


@interface WebBL : NSObject

@property (nonatomic,weak) id<WebBLDelegate>delegate;

#pragma mark -  管理类的单例
+ (id)sharedManager;

#pragma mark - 服务网点接口
/**
 服务网点接口
 @param keywords 搜索关键字
 @param bankMark 银行编号
 @param pageNum 页数
 @param pageSize 每页列表数量
 @param isMaked 0：不可制卡 1：可制卡
 @param isResetPassword 0：不可重置 1：可重置
 */
-(void)queryNetWorkPointWithKeyWords:(NSString*)keywords andbankMark:(NSString*)bankMark andpageNum:(int)pageNum andpageSize:(int)pageSize isMaked:(NSString *)isMaked isResetPassword:(NSString *)isResetPassword;

#pragma mark - 修改登录密码接口
/**
 修改登录密码接口

 @param mobile 手机号码
 @param oldpsd 旧密码
 @param newpsd 新密码
 @param againpsd 确认密码
 @param validCode 验证码
 @param token token
 */
-(void)ChangLoginPsdWithMobile:(NSString*)mobile andOldPsd:(NSString*)oldpsd andNewPsd:(NSString*)newpsd andAgainPsd:(NSString*)againpsd andvalidCode:(NSString*)validCode andaccessToken:(NSString*)token;

#pragma mark - 获取用户家庭住址
/**
 获取用户家庭住址

 @param access_token token
 */
-(void)queryHomeAddressWithAccessToken:(NSString*)access_token;

#pragma mark - 添加/修改用户家庭住址
/**
 添加/修改用户家庭住址

 @param access_token token
 @param devicetype 设备类型
 @param address 地址
 */
-(void)ChangHomeAddressWithAccessToken:(NSString*)access_token andDeviceType:(NSString*)devicetype andAddress:(NSString*)address;

#pragma mark - 获取公共汽车停车位信息

/**
 获取公共汽车停车位信息

 @param lon 经度
 @param lat 纬度
 @param type 停车场类型A 停车场 B 道路停车
 @param pageNo 页码
 @param pageSize 每页条数
 */
-(void)queryPublicParksWithLongitude:(NSString*)lon andLatitude:(NSString*)lat andType:(NSString*)type andpageNo:(int)pageNo andpageSize:(int)pageSize;

#pragma mark - 获取公共汽车停车位信息（含搜索版）

/**
 获取公共汽车停车位信息（含搜索版）

 @param log 经度
 @param lat 纬度
 @param keywords 搜索关键字
 @param type 停车场类型A 停车场 B 道路停车
 @param pageNo 页码
 @param pageSize 每页条数
 */
- (void)getPublicCarSearchListWithLongitude:(NSString *)log andLatitude:(NSString *)lat andKeywords:(NSString *)keywords andType:(NSString *)type andpageNo:(int)pageNo andpageSize:(int)pageSize;


#pragma mark - 获取公共汽车停车位单个站点信息
/**
 获取公共汽车停车位单个站点信息

 @param lon 定位经度
 @param lat 定位纬度
 @param Id 停车场ID
 */
-(void)queryParkInfoWithLongitude:(NSString*)lon andLatitude:(NSString*)lat andId:(NSString*)Id;


@end
