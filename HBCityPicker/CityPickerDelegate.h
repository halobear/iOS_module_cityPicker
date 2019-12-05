//
//  CityPickerDelegate.h
//  Teamwork
//
//  Created by monkey on 16/6/3.
//  Copyright © 2016年 刘～丹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ActionSheetPicker_3_0/ActionSheetPicker.h>
#import "CityModel.h"

@interface CityPickerDelegate : NSObject<ActionSheetCustomPickerDelegate>
{
    NSArray *provinceArr;
    NSArray *cityArr;
    NSArray *areaArr;
}

@property (nonatomic, strong) CityModel *province;
@property (nonatomic, strong) CityModel *city;
@property (nonatomic, strong) CityModel *area;

@property (nonatomic, copy) void(^pickerDidSelectBlock)(CityModel *province,CityModel *city, CityModel *area);

@end
