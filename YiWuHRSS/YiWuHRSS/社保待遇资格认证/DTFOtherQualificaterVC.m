//
//  DTFOtherQualificaterVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFOtherQualificaterVC.h"
#import "DTFOtherQualiferCell.h"//其他社保待遇资格认证人员cell
#import "DTFAddOtherQualiferVC.h"//添加其他社保待遇认证
#import "HttpHelper.h"
#import "DTFOtherQualiferBean.h"
#import "MJExtension.h"
#import "DTFQualificationConfirmVC.h"
#import "SZKAlterView.h"


#define URL_DELETE_MULTI_QUALIFER  @"/shebao/deleteOtherInsured.json"
#define URL_IS_ABLE_TO_QUALIFER     @"/shebao/attestInformation.json" //判断是否可以进行资格认证


@interface DTFOtherQualificaterVC ()<UITableViewDataSource,UITableViewDelegate>


/** 背景View，覆盖在没有其他参保人页面的上面，如果有其他参保人在上面加载一个tableView */
@property (weak, nonatomic) IBOutlet UIView *bgView;

/** 其他社保待遇资格认证人员列表 */
@property (strong, nonatomic) UITableView * otherQualiferTabelView;

/** 删除按钮 */
@property (strong, nonatomic) UIButton * deleteButton;
/** 添加按钮 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/** 其他人员列表 */
@property (strong, nonatomic) NSMutableArray<DTFOtherQualiferBean *> * qualiferList;
/** 处于删除状态 */
@property (assign, nonatomic) BOOL isDeleting;
/** 最多可以添加的人数 */
@property (assign, nonatomic) NSInteger maxSize;

@property(nonatomic ,strong) MBProgressHUD * HUD;



/**
 底部添加按钮的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForAddButton;

/**
 添加按钮和bgView的底部
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonToBgBottom;


@end

@implementation DTFOtherQualificaterVC


/**
 懒加载其他社保待遇资格认证人员列表

 @return 其他社保待遇资格认证人员列表
 */
-(UITableView *)otherQualiferTabelView{
    
    if(_otherQualiferTabelView == nil){
        
        _otherQualiferTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 -45)];
        _otherQualiferTabelView.delegate = self;
        _otherQualiferTabelView.dataSource = self;
        _otherQualiferTabelView.rowHeight = 83;
        _otherQualiferTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.bgView addSubview:_otherQualiferTabelView];
    }
    return _otherQualiferTabelView;
}


-(NSMutableArray<DTFOtherQualiferBean *> *)qualiferList{
    
    if(_qualiferList == nil){
        
        _qualiferList = [NSMutableArray array];
    }
    return _qualiferList;
}


/**
 删除按钮被点击时执行相关操作

 @param isDeleting 删除按钮被点击时
 */
-(void)setIsDeleting:(BOOL)isDeleting{
    
    _isDeleting = isDeleting;

    for (DTFOtherQualiferBean * bean in self.qualiferList) {
        bean.isDeleting = isDeleting;
        bean.isSelected = NO;
    }
    
    if(_isDeleting){
        //显示删除按钮
        [self.addButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"icon_rz_delete"] forState:UIControlStateNormal];
        [self.addButton setTitle:@"删除" forState:UIControlStateHighlighted];
        [self.addButton setImage:[UIImage imageNamed:@"icon_rz_delete"] forState:UIControlStateHighlighted];
    }else{
        //显示添加按钮
        [self.addButton setTitle:@"添加" forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"icon_rz_add"] forState:UIControlStateNormal];
        [self.addButton setTitle:@"添加" forState:UIControlStateHighlighted];
        [self.addButton setImage:[UIImage imageNamed:@"icon_rz_add"] forState:UIControlStateHighlighted];
    }
    
    [self.otherQualiferTabelView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"社保待遇资格认证";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加右侧按钮
    
    
    [self.otherQualiferTabelView registerNib:[UINib nibWithNibName:@"DTFOtherQualiferCell" bundle:nil] forCellReuseIdentifier:@"DTFOtherQualiferCell"];
    
    //tableHeaderView中的删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(SCREEN_WIDTH - 50 - 15, 0, 60, 40);
    deleteButton.titleLabel.textColor = [UIColor blueColor];
    [deleteButton setTitleColor:[UIColor colorWithRed:36/255.0 green:157/255.0 blue:238/255.0 alpha:1.0] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor colorWithRed:36/255.0 green:157/255.0 blue:238/255.0 alpha:1.0] forState:UIControlStateSelected];
    deleteButton.font = [UIFont systemFontOfSize:15.0];
    deleteButton.titleLabel.text = @"删除";
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitle:@"取消" forState:UIControlStateSelected];
    [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton = deleteButton;
    
    //添加按钮
    [self.addButton setTitle:@"添加" forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"icon_rz_add"] forState:UIControlStateNormal];
    [self.addButton setTitle:@"添加" forState:UIControlStateHighlighted];
    [self.addButton setImage:[UIImage imageNamed:@"icon_rz_add"] forState:UIControlStateHighlighted];
    self.addButton.hidden = YES;
    _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 );

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self getOtherQualiferList];
}




/**
 返回按钮点击
 */
-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - tabelView delegate and dataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.qualiferList.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DTFOtherQualiferCell *cell = [self.otherQualiferTabelView dequeueReusableCellWithIdentifier:@"DTFOtherQualiferCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.qualiferBean = self.qualiferList[indexPath.row];
    
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    
    UILabel * tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 20)];
    tipsLabel.text = @"其他人员信息";
    tipsLabel.font = [UIFont systemFontOfSize:12.0];
    tipsLabel.textColor = [UIColor colorWithHex:666666];
    [view addSubview:tipsLabel];
    [view addSubview:self.deleteButton];
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel * tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH-10, 30)];
    tipsLabel.textAlignment = NSTextAlignmentRight;
    tipsLabel.textColor = [UIColor colorWithHex:999999];
    tipsLabel.font = [UIFont systemFontOfSize:12.0];
    tipsLabel.text = [NSString stringWithFormat:@"最多添加%li人，还可添加%li人",self.maxSize,self.maxSize - self.qualiferList.count];
    
    NSMutableAttributedString *attribtedS = [[NSMutableAttributedString alloc] initWithAttributedString:tipsLabel.attributedText];
    [attribtedS addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(4, 1)];
    [attribtedS addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(11, 1)];
    [tipsLabel setAttributedText:attribtedS];
    
    [view addSubview:tipsLabel];
    
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    
    return 40;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.qualiferList[indexPath.row].isSelected = !self.qualiferList[indexPath.row].isSelected;
    
    //判断底部按钮是显示添加还是显示删除
    BOOL isHasSelectedBean = NO;
    for (DTFOtherQualiferBean * bean in self.qualiferList) {
        if(bean.isSelected){
            isHasSelectedBean = YES;
        }
    }
    
    
    //如果现在不处于批量删除状态
    if(!self.isDeleting){

        //查询是否有资格
        [self getQualiferInfoWithOtherID:[NSString stringWithFormat:@"%li",[self.qualiferList[indexPath.row].ID integerValue]]];
        
    }

    
    [self.otherQualiferTabelView reloadData];
    
}



#pragma mark - 删除按钮点击事件

-(void)deleteButtonClick:(UIButton *)deleteButton{
    
    self.deleteButton.selected = !self.deleteButton.selected;
    
    //如果列表中已满5人，点击删除按钮时显示底部的添加按钮（此时为删除）
    if(self.deleteButton.selected){
        [UIView animateWithDuration:0.3 animations:^{
           self.addButton.hidden = NO;
            _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 - 45);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            //控制底部的添加按钮是否显示
            if((self.maxSize - self.qualiferList.count) <= 0 && self.maxSize != 0){
                
                self.addButton.hidden = YES;
                _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
            }else{
                self.addButton.hidden = NO;
                _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 - 45);
            }
        }];
    }
    
    

    if(self.deleteButton.isSelected){
        NSLog(@"删除按钮选中");
        self.isDeleting = YES;
    }else{
        NSLog(@"删除按钮未选中");
        self.isDeleting = NO;
    }
}

#pragma mark - 添加按钮点击事件
- (IBAction)addButtonClick:(UIButton *)sender {
    DMLog(@"添加按钮点击事件");
    
    if([self.addButton.titleLabel.text isEqualToString:@"添加"]){
        
        DTFAddOtherQualiferVC *vc = [[DTFAddOtherQualiferVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([self.addButton.titleLabel.text isEqualToString:@"删除"]){
        
        //1.是否有选中要删除的人员
        BOOL isHasDeleteQuailer = NO;
        for (DTFOtherQualiferBean *bean in self.qualiferList) {
            
            //如果是选中状态，拼接要删除的ID
            if(bean.isSelected){
                isHasDeleteQuailer = YES;
            }
        }
        if(!isHasDeleteQuailer){
            [MBProgressHUD showError:@"请选择需要删除的其他人信息"];
            return ;
        }
        
        //2.有选中要删除的人员时，弹出删除的警告
        SZKAlterView *alertView=[SZKAlterView alterViewWithTitle:@"确认删除选中的其他人信息？" content:@"删除后，所选的其他人不能再进行社保待遇资格认证，请谨慎操作！" cancel:@"取消" sure:@"确认删除" cancelBtClcik:^{
            //取消按钮点击事件
            DMLog(@"取消");
        } sureBtClcik:^{
            //确定按钮点击事件
            DMLog(@"确认删除");
            NSString * delete_ids = @"";
    
            for (DTFOtherQualiferBean *bean in self.qualiferList) {
    
                //如果是选中状态，拼接要删除的ID
                if(bean.isSelected){
                    if([delete_ids isEqualToString:@""]){
                        delete_ids = [delete_ids stringByAppendingString:[NSString stringWithFormat:@"%@",bean.ID]];
                    }else{
                        delete_ids = [delete_ids stringByAppendingString:[NSString stringWithFormat:@";%@",bean.ID]];
                    }
                }
            }
            DMLog(@"要删除的-IDs-%@",delete_ids);
    
            [self deleteButtonClick:self.deleteButton];
            [self deleteQualifersWith:delete_ids];

        }];
        [self.view addSubview:alertView];
    }
}



#pragma mark - 网络请求-获取其他社保待遇人员列表
-(void)getOtherQualiferList{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"%@/shebao/OtherInsuredList.json",HOST_TEST];
    
    
    self.HUD.labelText = @"加载中";
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary * dictData= [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){
            
            self.qualiferList = [DTFOtherQualiferBean mj_objectArrayWithKeyValuesArray:dictData[@"data"][@"othersList"]];

            self.maxSize = [dictData[@"data"][@"size"] integerValue];
            
            
            //控制底部的添加按钮是否显示
            if((self.maxSize - self.qualiferList.count) <= 0 && self.maxSize != 0){
                
                self.addButton.hidden = YES;
                _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
            }else{
                self.addButton.hidden = NO;
                _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 - 45);
            }
            
        }else{
            
            [MBProgressHUD showError:dictData[@"message"]];
        }

        //控制整个tableView是否显示
        if(self.qualiferList.count == 0){
            
            self.otherQualiferTabelView.hidden = YES;
        }else{
            
            self.otherQualiferTabelView.hidden = NO;
        }
        
        [self.otherQualiferTabelView reloadData];
            
        DMLog(@"获取其他社保待遇人员列表--%@",dictData);
         
        
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"获取其他社保待遇人员列表--%@",error);
        self.addButton.hidden = NO;
        _otherQualiferTabelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64 - 45);
        
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


#pragma mark - deleteQualifers 批量删除其他社保待遇资格认证的列表中的人员

-(void)deleteQualifersWith:(NSString *)qualifersID{

    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"id_list"] = qualifersID;
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_DELETE_MULTI_QUALIFER];
    
    self.HUD.labelText = @"";
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary * dictData= [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){
            
            DMLog(@"%@",dictData[@"message"]);
            //[MBProgressHUD showSuccess:dictData[@"message"]];
            self.isDeleting = NO;
            
            //重新获取，其他社保待遇认证列表中的数据
            [self getOtherQualiferList];
            
        }else{
            
            [MBProgressHUD showError:dictData[@"message"]];
        }
        

        DMLog(@"%@",dictData);
        
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"获取其他社保待遇人员列表--%@",error);
    
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


/**
 如果是来自其他社保待遇资格认证需要在本页面获取用户的信息
 */
-(void)getQualiferInfoWithOtherID:(NSString *)other_id{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"other_id"] = other_id;
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_IS_ABLE_TO_QUALIFER];
    
    DMLog(@"本人认证资格--URL--%@",url);
    DMLog(@"本人认证资格--param--%@",param);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"添加其他资格认证人员-网络请求返回-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            DTFQualificationConfirmVC *vc = [[DTFQualificationConfirmVC alloc]init];
            vc.isFromOtherQualiferList = YES;
            vc.name = dictData[@"data"][@"name"];
            vc.shbzh = dictData[@"data"][@"shbzh"];
            vc.serialNumber = dictData[@"data"][@"serialNumber"];
            vc.ID = [other_id integerValue];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{//本人认证资格
            
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----本人认证资格--请求失败--%@",error);
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"";
}

- (void)dealloc{
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}






@end
