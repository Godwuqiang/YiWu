//
//  DTFVisiterFamilyRecordVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  探亲登记记录详情页-不可编辑

#import "DTFVisiterFamilyRecordVC.h"
#import "DTFRecordDetailsModel.h"

@interface DTFVisiterFamilyRecordVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPhoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *azdzLabel;
@property (weak, nonatomic) IBOutlet UILabel *jtdzLabel;
@property (weak, nonatomic) IBOutlet UILabel *ydazyyLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstHospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondHospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdHospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthHospitalLabel;

@property (weak, nonatomic) IBOutlet UILabel *djbhqfsLabel;         //登记表获取方式
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;          //登记表获取方式描述

@property (weak, nonatomic) IBOutlet UIImageView *documentPic;      //证明材料图片

@property (weak, nonatomic) IBOutlet UILabel *documentLabel;






@end

@implementation DTFVisiterFamilyRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}

-(void)setupUI{
    
    self.title = @"探亲登记记录";
    
    self.firstHospitalLabel.layer.borderWidth = 1;
    self.firstHospitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    
    self.secondHospitalLabel.layer.borderWidth = 1;
    self.secondHospitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    
    self.thirdHospitalLabel.layer.borderWidth = 1;
    self.thirdHospitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    
    self.forthHospitalLabel.layer.borderWidth = 1;
    self.forthHospitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    
    NSString *encodedImageStr = [CoreArchive strForKey:LOGIN_USER_PNG];
    if ([Util IsStringNil:encodedImageStr]) {
        self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
    }else{
        @try {
            NSData *encodeddata = [NSData dataFromBase64String:encodedImageStr];
            UIImage *encodedimage = [UIImage imageWithData:encodeddata];
            self.imageView.image = encodedimage;
        } @catch (NSException *exception) {
            self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
        }
    }
    
    self.userNameLabel.text = [CoreArchive strForKey:LOGIN_NAME];
    //手机号脱敏
    NSString * phone = [[CoreArchive strForKey:LOGIN_APP_MOBILE] substringToIndex:3];
    phone = [NSString stringWithFormat:@"%@****",phone];
    phone = [phone stringByAppendingString:[[CoreArchive strForKey:LOGIN_APP_MOBILE] substringFromIndex:7]];
    self.userPhoneLabel.text = phone;
    
    self.documentLabel.layer.borderWidth = 1.0;
    self.documentLabel.layer.borderColor = [UIColor colorWithHex:0x7ea4b0].CGColor;

}


-(void)setRecordDetailsModel:(DTFRecordDetailsModel *)recordDetailsModel{
    
    _recordDetailsModel = recordDetailsModel;
    self.nameLabel.text = _recordDetailsModel.name;
    self.mobileLabel.text = _recordDetailsModel.mobile;
    self.azdzLabel.text = _recordDetailsModel.azdz;
    self.jtdzLabel.text = _recordDetailsModel.jtdz;
    self.ydazyyLabel.text = _recordDetailsModel.ydazyy;
    self.startTimeLabel.text = _recordDetailsModel.startTime;
    self.endTimeLabel.text = _recordDetailsModel.endTime;
    self.djbhqfsLabel.text = _recordDetailsModel.djbhqfs;
    self.remarkLabel.text = _recordDetailsModel.remark;
    
    if(_recordDetailsModel.azyy.count == 1){//显示一个医院
        self.firstHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[0]];
        self.secondHospitalLabel.hidden = YES;
        self.thirdHospitalLabel.hidden = YES;
        self.forthHospitalLabel.hidden = YES;
    }else if(_recordDetailsModel.azyy.count == 2){//显示一个医院
        self.firstHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[0]];
        self.secondHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[1]];
        self.thirdHospitalLabel.hidden = YES;
        self.forthHospitalLabel.hidden = YES;
    }else if (_recordDetailsModel.azyy.count == 3){//显示一个医院
        self.firstHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[0]];
        self.secondHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[1]];
        self.thirdHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[2]];
        self.forthHospitalLabel.hidden = YES;
    }else if (_recordDetailsModel.azyy.count == 4){//显示一个医院
        self.firstHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[0]];
        self.secondHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[1]];
        self.thirdHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[2]];
        self.forthHospitalLabel.text = [self showHospitalNameWith:_recordDetailsModel.azyy[3]];
    }else{//不显示医院
        self.firstHospitalLabel.hidden = YES;
        self.secondHospitalLabel.hidden = YES;
        self.thirdHospitalLabel.hidden = YES;
        self.forthHospitalLabel.hidden = YES;
    }
    
    if(_recordDetailsModel.documentPic != nil && ![_recordDetailsModel.documentPic isEqualToString:@""]){
        NSData *encodeddata = [NSData dataFromBase64String:_recordDetailsModel.documentPic];
        UIImage *encodedimage = [UIImage imageWithData:encodeddata];
        self.documentPic.image = encodedimage;
    }
    
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        return 68.0;
    }else if (indexPath.row == 1){
        return 50.0;
    }else if (indexPath.row == 2){
        return 50.0;
    }else if (indexPath.row == 3){
        return 50.0;
    }else if (indexPath.row == 4){
        return 65.0;
    }else if (indexPath.row == 5){
        return 50.0;
    }else if (indexPath.row == 6){
        return 40.0;
    }else if (indexPath.row == 7){
        return 50.0;
    }else if (indexPath.row == 8){
        return 50.0;
    }else if (indexPath.row == 9){
        return 20.0;
    }else if (indexPath.row == 10){
        
        return 50.0;
    }else if (indexPath.row == 11){
        if(_recordDetailsModel.azyy.count == 0){
            return 0.01;
        }
        if(_recordDetailsModel.azyy.count <3){
            return 70.0;
        }else if(_recordDetailsModel.azyy.count>2){
            return 130.0;
        }else{
            return 0.0;
        }
        return 130.0;
    }else if (indexPath.row == 12){
        return 20.0;
    }else if (indexPath.row == 13){
        return 60.0;
    }else if (indexPath.row == 14){
        return [_recordDetailsModel.remark getHeightBySizeOfFont:12 width:([UIScreen mainScreen].bounds.size.width-40)]+20;
    }else if (indexPath.row == 15){
        return 0.1;
    }else if (indexPath.row == 16){
        return 0.1;
    }else{
        return 0.1;
    }
}


-(NSString *)showHospitalNameWith:(NSString *)totalString{
    
    totalString = [[totalString componentsSeparatedByString:@";"] firstObject];
    return totalString;
}



@end
