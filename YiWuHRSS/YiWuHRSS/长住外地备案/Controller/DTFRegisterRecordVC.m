//
//  DTFRegisterRecordVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFRegisterRecordVC.h"
#import "DTFRegistRecordCell.h"
#import "DTFRemoteRecordVC.h"
#import "DTFVisiterFamilyRecordVC.h"
#import "DTFExpatriateRecordVC.h"
#import "DTFBaseRegisterRecordVC.h"
#import "DTFRegistRecordModel.h"
#import "HttpHelper.h"
#import "MJExtension.h"

#define URL_GetRecordList        @"/shebao/recordList.json"                   //获取记录列表


@interface DTFRegisterRecordVC ()

@property (strong, nonatomic) NSMutableArray<DTFRegistRecordModel*> * recordList;              //记录列表
@property (strong, nonatomic) NSNumber * pageNo;                        //页码
@property (strong, nonatomic) NSNumber * pageSize;                      //每页显示数量

@property (weak, nonatomic)  UIImageView * noDataImageView;             //无数据提示图片
@property (weak, nonatomic)  UILabel * tipsLabel;                       //无数据提示Label

@end

@implementation DTFRegisterRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

-(void)setupUI{
    
    if([_type isEqualToString:@"1"]){
        
        self.title = @"异地安置登记记录";
        
    }else if([_type isEqualToString:@"2"]){
        
        self.title = @"探亲登记记录";
        
    }else{
        self.title = @"外派人员登记记录";
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DTFRegistRecordCell" bundle:nil] forCellReuseIdentifier:@"DTFRegistRecordCellID"];
    self.tableView.rowHeight = 158.0;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    self.tableView.header = [MJRefreshHeader headerWithRefreshingBlock:^{
        self.pageNo = @1;
        self.pageSize = @10;
        [self getRecordList];
    }];
    
    [self.tableView.header beginRefreshing];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {


    
    return self.recordList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DTFRegistRecordModel * recordModel = self.recordList[indexPath.row];
    if([recordModel.remark isEqualToString:@""]){
        return 158.0;
    }else{
        return 188.0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DTFRegistRecordCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"DTFRegistRecordCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.recordModel = self.recordList[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    DTFBaseRegisterRecordVC * vc = [[DTFBaseRegisterRecordVC alloc]init];
    vc.type = _type;
    vc.apply_id = self.recordList[indexPath.row].applyId;
    vc.shzt = self.recordList[indexPath.row].shzt;
    vc.remark = self.recordList[indexPath.row].remark;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 获取登记记录列表
-(void)getRecordList{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"type"] = [NSString stringWithFormat:@"0%@",self.type];
    param[@"page_no"] = [NSString stringWithFormat:@"%@",self.pageNo];
    param[@"page_size"] = [NSString stringWithFormat:@"%@",self.pageSize];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_GetRecordList];
    
    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"获取登记记录列表-%@",dictData);
        NSLog(@"获取登记记录列表-message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            NSDictionary * dataDict = dictData[@"data"];
            self.recordList = [DTFRegistRecordModel mj_objectArrayWithKeyValuesArray:dataDict[@"recordList"]];
            
            //没有查到相关记录
            if(self.recordList.count ==0){
                [self setNoDataUI];
            }
        }else if ([dictData[@"resultCode"] integerValue] == 201){
            
            //没有查到相关记录
            if(self.recordList.count ==0){
                [self setNoDataUI];
            }
            
        }else{
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        [self.tableView.header endRefreshing];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        [self.tableView.header endRefreshing];
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
        
    }];
}


#pragma mark - 设置无数据页面
-(void)setNoDataUI{
    
    //按照屏幕等比例显示
    CGFloat x = (SCREEN_WIDTH/2.0)-90;
    CGFloat y = SCREEN_HEIGHT * (40/571.0);
    CGFloat width = SCREEN_WIDTH*(180/375.0);
    CGFloat height = SCREEN_WIDTH*(180/375.0)*(195/180.0);
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_no_record"]];
    imageView.frame = CGRectMake(x, y, width, height);
    self.noDataImageView = imageView;
    [self.view addSubview:imageView];
    
    UILabel *tipsLabel = [[UILabel alloc]init];
    tipsLabel.frame  = CGRectMake(0, y + height + 10, SCREEN_WIDTH, 30);
    tipsLabel.text = @"当前暂无相关记录~";
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor colorWithHex:0x666666];
    self.tipsLabel= tipsLabel;
    [self.view addSubview:tipsLabel];
}






@end
