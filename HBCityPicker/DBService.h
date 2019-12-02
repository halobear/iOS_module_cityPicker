//
//  DBService.h
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "JYDataBase.h"
#import "HBShopDB.h"

@interface DBService : JYDataBase


+ (instancetype)shared;

//- (NSArray<ProvinceModel *> *)getAllProvice;

- (NSArray<CityModel *> *)getCitysByConditions:(void (^)(JYQueryConditions *make))block;

//- (NSArray<ProvinceModel *> *)getProviceInfoByConditions:(void (^)(JYQueryConditions *make))block;
//- (NSArray<CityModel *> *)getAllCitys:(NSArray<NSString *> *)provinceId;

#pragma mark - 播放记录

//- (NSArray <PlayRecordModel *> *)getAllPlayRecord;
//
//- (NSArray <PlayRecordModel *> *)getPlayRecordsByConditions:(void (^)(JYQueryConditions *make))block;
//- (PlayRecordModel *)getPlayRecords:(NSString *)recordId;
//
//- (void)updateRecord:(PlayRecordModel *)model;

@end
