//
//  HSAddressPickerVC.m
//  HSPickerViewDemo
//
//  Created by husong on 2017/10/27.
//  Copyright © 2017年 husong. All rights reserved.
//

#import "HSAddressPickerVC.h"

@interface HSAddressPickerVC ()
// 数据源数组
@property(nonatomic,strong)NSMutableArray *allProvinces;// 所有省信息
@property(nonatomic,strong)NSMutableArray *allCities;// 一个省的所有城市信息
@property(nonatomic,strong)NSMutableArray *currentCityArray;// 当前省的 所有城市名称
@property(nonatomic,strong)NSMutableArray *currentAreaArray;// 当前市的 所有区名称

/// 当前省的 所有城市编码
@property(nonatomic, strong)NSMutableArray *currentCity_codeArray;
/// 当前市的 所有区名编码
@property(nonatomic, strong)NSMutableArray *currentArea_codeArray;


// 记录当前行
@property(nonatomic,assign) NSInteger provinceIndex;
@property(nonatomic,assign) NSInteger cityIndex;
// 记录当前省市区
@property(nonatomic,copy) NSString *currentProvince;
@property(nonatomic,copy) NSString *currentCity;
@property(nonatomic,copy) NSString *currentArea;

/// 省编码
@property(nonatomic, copy) NSString *provice_code;
/// 市编码
@property(nonatomic, copy) NSString *city_code;
/// 区县编码
@property (nonatomic, copy) NSString *area_code;


@end

@implementation HSAddressPickerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.pickerTitle = @"请选择地区";
    [self allProvinces];// 初始化所有省数据
    [self currentCityArray]; //初始化当前市数据
    [self currentCity_codeArray]; // 初始化当前市编码数据
    [self currentAreaArray];// 初始化当前区数组
    [self currentArea_codeArray]; // 初始化当前区编码
    
    self.dataArray = @[_allProvinces,_currentCityArray,_currentAreaArray];
    
//    [self.pickerView selectRow:(NSInteger) inComponent:(NSInteger) animated:(BOOL)]
//    [self.pickView selectRow:[CoreArchive intForKey:PROVICE_COMPONENT_INDEX] inComponent:0 animated:YES];
//    [self.pickView selectRow:[CoreArchive intForKey:CITY_COMPONENT_INDEX] inComponent:1 animated:YES];
//    [self.pickView selectRow:[CoreArchive intForKey:AREA_COMPONENT_INDEX] inComponent:2 animated:YES];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            return [self.allProvinces[row] objectForKey:@"divisionName"];
            break;
        case 1:
            return self.currentCityArray[row];
            break;
        case 2:
            return self.currentAreaArray[row];
            break;
        default:
            break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    
//    NSLog(@"00000000000000000000000: %li", row);
    
    if (component == 0) {
        
//        NSLog(@"000000000000000000: %li", row);
        [CoreArchive setInt:row key:PROVICE_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:CITY_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:AREA_COMPONENT_INDEX];
        
        // 重置当前城市数组
        self.provinceIndex = row;
        [self resetCityArray];
        [self resetCity_codeArray];
        // 刷新城市列表,并滚动至第一行
        [self scrollToTopRowAtComponent:1];
        // 记录当前城市
        _currentCity = _currentCityArray[0];
        // 记录当前城市编码
        _city_code = _currentCity_codeArray[0];
        // 根据当前城市重置区数组
        self.cityIndex = [_currentCityArray indexOfObject:_currentCity];
        [self resetAreaArray];
        // 刷新区列表,并滚动至第一行
        [self scrollToTopRowAtComponent:2];
        // 记录当前
        _currentProvince = [_allProvinces[row] objectForKey:@"divisionName"];
        // 记录当前省编码
        _provice_code = [_allProvinces[row] objectForKey:@"divisionCode"];
        // 记录当前区
        if (_currentAreaArray.count) {
            _currentArea = _currentAreaArray[0];
        }
        else{
            _currentArea = @"";
        }
        
        // 记录当前区编码
        if (_currentArea_codeArray.count) {
            _area_code = _currentArea_codeArray[0];
        }
        else{
            _area_code = @"";
        }
    }
    else if(component == 1){
        
//        NSLog(@"1111111111111111111111: %li", row);
        [CoreArchive setInt:row key:CITY_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:AREA_COMPONENT_INDEX];
        
        // 记录当前城市
        _currentCity = _currentCityArray[row];
        // 记录当前城市编码
        _city_code = _currentCity_codeArray[row];
        // 根据当前城市重置区数组
        self.cityIndex = row;
        [self resetAreaArray];
        // 刷新区列表,并滚动至第一行
        [self scrollToTopRowAtComponent:2];
        if (_currentAreaArray.count) {
            _currentArea = _currentAreaArray[0];
        }
        else{
            _currentArea = @"";
        }
        if (_currentArea_codeArray.count) {
            _area_code = _currentArea_codeArray[0];
        }
        else{
            _area_code = @"";
        }
        
    }
    else{
        
//        NSLog(@"2222222222222222: %li", row);
        [CoreArchive setInt:row key:AREA_COMPONENT_INDEX];
        // 重置当前区
        if (_currentAreaArray.count) {
            _currentArea = _currentAreaArray[row];
        }
        else{
            _currentArea = @"";
        }
        // 重置当前区编码
        if (_currentArea_codeArray.count) {
            _area_code = _currentArea_codeArray[row];
        }
        else{
            _area_code = @"";
        }
        
    }
    
    [pickerView reloadComponent:component];
}

#pragma mark - privateMethods
-(void)cancleAction{
    [super cancleAction];
}

-(void)ensureAction{
    [super ensureAction];
    
    if ([self.delegate respondsToSelector:@selector(addressPicker:selectedProvince:city:area:ProvinceCode:CityCode:AreaCode:)]) {
        //        [self.delegate addressPicker:self selectedProvince:_currentProvince city:_currentCity area:_currentArea];
        //        [self.delegate addressPicker:self selectedProvince:_provice_code city:_city_code area:_area_code];
        [self.delegate addressPicker:self selectedProvince:_currentProvince city:_currentCity area:_currentArea ProvinceCode:_provice_code CityCode:_city_code AreaCode:_area_code];
    }
}

/** 获取plist文件路径 */
-(NSString*)addressFilePath{
    return [[NSBundle mainBundle] pathForResource:@"HS_address.plist" ofType:nil];
}

/** 获取当前省 的市数组 */
-(void)resetCityArray{
    [self.currentCityArray removeAllObjects];
    // 当前省信息字典
    NSDictionary *currentPorvinceDict = self.allProvinces[_provinceIndex];
    // 当前省编码
    NSString *cityPostcode = [currentPorvinceDict objectForKey:@"divisionCode"];
    // 根据省编码 获取 市信息数组
    NSArray *cityArr = [[NSDictionary dictionaryWithContentsOfFile:[self addressFilePath]] objectForKey:cityPostcode];
    self.allCities = [NSMutableArray arrayWithArray:cityArr];
    // 重置城市数组
    for (NSDictionary *dict in cityArr) {
        [_currentCityArray addObject:[dict objectForKey:@"divisionName"]];
    }
}

/** 获取当前省 的市编码数组 */
-(void)resetCity_codeArray{
    [self.currentCity_codeArray removeAllObjects];
    // 当前省信息字典
    NSDictionary *currentPorvinceDict = self.allProvinces[_provinceIndex];
    // 当前省编码
    NSString *cityPostcode = [currentPorvinceDict objectForKey:@"divisionCode"];
    // 根据省编码 获取 市信息数组
    NSArray *cityArr = [[NSDictionary dictionaryWithContentsOfFile:[self addressFilePath]] objectForKey:cityPostcode];
    self.allCities = [NSMutableArray arrayWithArray:cityArr];
    // 重置城市数组
    for (NSDictionary *dict in cityArr) {
        [_currentCity_codeArray addObject:[dict objectForKey:@"divisionCode"]];
    }
    
}

/** 根据当前城市编号 获取区数组 */
-(void)resetAreaArray{
    [self.currentAreaArray removeAllObjects];
    [self.currentArea_codeArray removeAllObjects];
    NSString *currentCityPostcode = [_allCities[_cityIndex] objectForKey:@"divisionCode"];
    // 根据市编码 获取 区信息数组
    NSArray *areaArr = [[NSDictionary dictionaryWithContentsOfFile:[self addressFilePath]] objectForKey:currentCityPostcode];
    // 重置区数组
    for (NSDictionary *dict in areaArr) {
        [_currentAreaArray addObject:[dict objectForKey:@"divisionName"]];
        [_currentArea_codeArray addObject:[dict objectForKey:@"divisionCode"]];
    }
}

/** 刷新区列表,并滚动至第一行 */
-(void)scrollToTopRowAtComponent:(NSInteger)component{
    [self.pickView reloadComponent:component];
    [self.pickView selectRow:0 inComponent:component animated:YES];
}

#pragma mark - lazy
/** 所有省字典数据 */
-(NSMutableArray*)allProvinces{
    if (!_allProvinces) {
        _allProvinces = [[NSDictionary dictionaryWithContentsOfFile:[self addressFilePath]] objectForKey:@"provinces"];
        _currentProvince = [_allProvinces[0] objectForKey:@"divisionName"];// 初始化当前省
        _provice_code = [_allProvinces[0] objectForKey:@"divisionCode"]; // 初始化当前省编码
    }
    return _allProvinces;
}

/** 市名称 数组 */
-(NSMutableArray*)currentCityArray{
    if (!_currentCityArray) {
        _currentCityArray = [[NSMutableArray alloc] init];
        // 重置城市数组
        [self resetCityArray];
        _currentCity = _currentCityArray[0];
    }
    return _currentCityArray;
}

/** 市编码 数组 */
-(NSMutableArray *)currentCity_codeArray{
    if (!_currentCity_codeArray) {
        _currentCity_codeArray = [[NSMutableArray alloc] init];
        // 重置城市编码数组
        [self resetCity_codeArray];
        _city_code = _currentCity_codeArray[0];
    }
    return _currentCity_codeArray;
}

/** 区名称 数组 */
-(NSMutableArray*)currentAreaArray{
    if (!_currentAreaArray) {
        _currentAreaArray = [[NSMutableArray alloc] init];
        // 重置区数组
        [self resetAreaArray];
        _currentArea = _currentAreaArray[0];
    }
    return _currentAreaArray;
}

/** 区编码 数组 */
-(NSMutableArray *)currentArea_codeArray{
    if (!_currentArea_codeArray) {
        _currentArea_codeArray = [[NSMutableArray alloc] init];
        // 重置区数组
        [self resetAreaArray];
        _area_code = _currentArea_codeArray[0];
    }
    return _currentArea_codeArray;
}

@end
