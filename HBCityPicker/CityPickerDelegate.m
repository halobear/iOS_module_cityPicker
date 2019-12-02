//
//  CityPickerDelegate.m
//  Teamwork
//
//  Created by monkey on 16/6/3.
//  Copyright © 2016年 刘～丹. All rights reserved.
//

#import "CityPickerDelegate.h"
#import "DBService.h"
#import "CityModel.h"

@implementation CityPickerDelegate

-(instancetype)init
{
    if (self = [super init]) {
      
        provinceArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
            make.field(@"level").equalTo(@"2");
        }];
        
        //直辖市判断 北京：2 天津：19 上海：793 重庆：2241
        CityModel *provinceModel = [provinceArr firstObject];
        self.province = provinceModel;
        
//        if (provinceModel.code.intValue == 110100 || provinceModel.code.intValue == 120100  || provinceModel.code.intValue == 310000 ||provinceModel.code.intValue == 500000 ) {
        
//        if (provinceModel.code.intValue == 110100 ) {
//
//            cityArr = @[provinceModel];
//            areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//                make.field(@"level").equalTo(provinceModel.code);
//            }];
//            
//            self.city = cityArr[0];
//            self.area = areaArr[0];
//
//            
//        }else {
//            cityArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//                make.field(@"parent_id").equalTo(provinceModel.code);
//            }];
//            CityModel *cityModel = [cityArr firstObject];
//            areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//                make.field(@"parent_id").equalTo(cityModel.code);
//            }];
//            
//            self.city = cityModel;
//            self.area = areaArr[0];
//
//        }
        
        cityArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
            make.field(@"parent_id").equalTo(provinceModel.code);
        }];
        CityModel *cityModel = [cityArr firstObject];
        areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
            make.field(@"parent_id").equalTo(cityModel.code);
        }];
        
        self.city = cityModel;
        self.area = areaArr[0];

        
    }
    return self;
    
}

-(void)reloadCity
{
//    if (self.province.code.intValue == 110100 || self.province.code.intValue == 120100  || self.province.code.intValue == 310000 ||self.province.code.intValue == 500000 ) {
//        
//        cityArr = @[self.province];
//        areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//            make.field(@"parent_id").equalTo(self.province.code);
//        }];
//        
//        self.city = cityArr[0];
//        self.area = areaArr[0];
//
//        
//    }else
//    {
//        cityArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//            make.field(@"parent_id").equalTo(self.province.code);
//        }];
//        CityModel *cityModel = [cityArr firstObject];
//        areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
//            make.field(@"parent_id").equalTo(cityModel.code);
//        }];
//        
//        self.city = cityArr[0];
//        self.area = areaArr[0];
//    }
    
    cityArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
        make.field(@"parent_id").equalTo(self.province.code);
    }];
    CityModel *cityModel = [cityArr firstObject];
    areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
        make.field(@"parent_id").equalTo(cityModel.code);
    }];
    
    self.city = cityArr[0];
    self.area = areaArr[0];
}

-(void)reloadArea
{
    areaArr = [[DBService shared] getCitysByConditions:^(JYQueryConditions *make) {
        make.field(@"parent_id").equalTo(self.city.code);
    }];
    self.area = areaArr[0];
}


#pragma mark - ActionSheetCustomPickerDelegate Optional's
/////////////////////////////////////////////////////////////////////////

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView {
    //不好用
//    actionSheetPicker.toolbarButtonsColor = UIColor.blackColor;
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:actionSheetPicker
//                                                                               action:@selector(actionPickerCancel:)];
//    barButton.tintColor = UIColor.blackColor;
//    barButton.title = @"取消";
//    [actionSheetPicker setCancelButton:barButton];

    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    
//    NSString *resultMessage;
    if (self.province && self.city && self.area) {
        
//        resultMessage = [NSString stringWithFormat:@"%@ %@ %@ selected.",
//                         self.province.name,
//                         self.city.name,
//                         self.area.name];
        
    }
    if (self.pickerDidSelectBlock) {
        self.pickerDidSelectBlock(self.province,self.city,self.area);
    }
//    [[[UIAlertView alloc] initWithTitle:@"Success!" message:resultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIPickerViewDataSource Implementation
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Returns
    switch (component) {
        case 0: return [provinceArr count];
        case 1: return [cityArr count];
        case 2: return [areaArr count];
            
        default:break;
    }
    return 0;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark UIPickerViewDelegate Implementation
/////////////////////////////////////////////////////////////////////////

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0: return UIScreen.main.bounds.width/3;
        case 1: return UIScreen.main.bounds.width/3;
        case 2: return UIScreen.main.bounds.width/3;
            
        default:break;
    }
    
    return 0;
}
/*- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
 {
 return
 }
 */
// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    CityModel *model = nil;
    NSString *title = nil;
    
    if (component == 0) {
        
        model = provinceArr[(NSUInteger) row];
        
    }else if (component == 1)
    {
        model = cityArr[(NSUInteger) row];
    }else if (component == 2)
    {
        model = areaArr[(NSUInteger) row];
    }
    title = model.name;
    return title;
}

/////////////////////////////////////////////////////////////////////////

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    switch (component) {
        case 0:
            self.province = provinceArr[(NSUInteger) row];
            
            [self reloadCity];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            
            return;
            
        case 1:
            self.city = cityArr[(NSUInteger) row];
            [self reloadArea];
            [pickerView reloadComponent:2];
            
            return;
        case 2:
            self.area = areaArr[(NSUInteger) row];
            return;
    
        default:break;
    }
}

@end
