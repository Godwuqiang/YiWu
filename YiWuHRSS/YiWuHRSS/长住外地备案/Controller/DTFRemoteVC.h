//
//  DTFRemoteVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  异地安置登记

#import <UIKit/UIKit.h>

@class DTFRegistModel;
@interface DTFRemoteVC : UITableViewController

@property (nonatomic ,strong) UIViewController * parentVC;
@property (nonatomic ,assign) BOOL  canGotoNext;            //是否可以进入下一步
@property (nonatomic ,assign) BOOL  canGotoBack;            //是否可以进行返回
@property (nonatomic ,assign) BOOL  isFromReregist;         //来着重新提交
@property (nonatomic, strong) DTFRegistModel * registModel;

@property (weak, nonatomic) IBOutlet UILabel *firstHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthHosipitalLabel;

@property (weak, nonatomic) IBOutlet UITextField *contactName;      //联系人姓名
@property (weak, nonatomic) IBOutlet UITextField *contactMobile;    //联系人联系方式
@property (weak, nonatomic) IBOutlet UILabel *address;              //安置地点
@property (weak, nonatomic) IBOutlet UITextView *addreeDetails;     //具体地址
@property (weak, nonatomic) IBOutlet UILabel *reason;               //安置原因
@property (weak, nonatomic) IBOutlet UILabel *startTime;            //开始时间
@property (weak, nonatomic) IBOutlet UILabel *endTime;              //结束时间
@property (weak, nonatomic) IBOutlet UILabel *selectedHospital;     //选择的医院
@property (weak, nonatomic) IBOutlet UILabel *djbhqfs;              //登记表获取方式 1自取；2邮寄；
@property (weak, nonatomic) IBOutlet UITableViewCell *selectedHospitalCell;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;          //获取方式详细


@property (assign, nonatomic) BOOL isTextViewFirstTimeEditding;     //具体地址第一次编辑

/// 选择的医院列表
@property (nonatomic, strong) NSArray *hospitalList;
/** 邮寄 */
@property (nonatomic,strong) NSString * yjRemark;
/** 自取 */
@property (nonatomic,strong) NSString * zqRemark;

@end
