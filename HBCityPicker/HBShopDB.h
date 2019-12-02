//
//  HBShopDB.h
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "JYDataBase.h"
#import "ProvinceTable.h"
#import "CityTable.h"
#import "PlayRecordTable.h"

@interface HBShopDB : JYDataBase

@property (nonatomic, strong) NSString * documentDirectory ;
@property (nonatomic, strong, readonly) ProvinceTable * provinceTable;
//@property (nonatomic, strong, readonly) CityTable * cityTable;
//@property (nonatomic, strong) PlayRecordTable *recordTable;

+ (instancetype)storage;


@end
