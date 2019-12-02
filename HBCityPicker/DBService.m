//
//  DBService.m
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "DBService.h"

@interface DBService ()

@property (nonatomic, strong) HBShopDB *hbshopDB;

@end


@implementation DBService

+ (instancetype)shared{
    static DBService *globalService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalService = [[DBService alloc] init];
        globalService.hbshopDB = [HBShopDB storage];
    });
    return globalService;
}

//-(NSArray<ProvinceModel *> *)getAllProvice
//{
//    return [self.hbshopDB.provinceTable getAllContent];
//}
- (NSArray<CityModel *> *)getCitysByConditions:(void (^)(JYQueryConditions *make))block
{
    return [self.hbshopDB.provinceTable getContentByConditions:block];
}
//- (NSArray<CityModel *> *)getAllCitys:(NSArray<NSString *> *)provinceId{
//    return [self.hbshopDB.cityTable getContentByIDs:provinceId];
//}
//-(NSArray<ProvinceModel *> *)getAllProvice
//{
//    return [self.hbshopDB.provinceTable getAllContent];
//}

#pragma mark - 播放记录

//- (NSArray <PlayRecordModel *> *)getAllPlayRecord
//{
//    return [self.hbshopDB.recordTable getAllContent];
//}
//- (NSArray <PlayRecordModel *> *)getPlayRecordsByConditions:(void (^)(JYQueryConditions *make))block
//{
//    return [self.hbshopDB.recordTable getContentByConditions:block];
//}
//- (PlayRecordModel *)getPlayRecords:(NSString *)recordId{
//    return [self.hbshopDB.recordTable getContentByID:recordId];
//}

//- (void)updateRecord:(PlayRecordModel *)model{
//    [self.hbshopDB.recordTable insertContent:model];
//}

@end
