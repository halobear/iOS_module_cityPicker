//
//  HBShopDB.m
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "HBShopDB.h"

#define dataBaseName @"HaloShop.db"

@interface HBShopDB()

@property (nonatomic, strong) ProvinceTable * provinceTable;

+ (instancetype)storage;

@end

@implementation HBShopDB
+ (instancetype)storage{
    HBShopDB *userStorage = [[HBShopDB alloc] init];
    [userStorage construct];
    return userStorage;
}

- (void)construct{
    NSLog(@"%@",self.documentDirectory);
    [self buildWithPath:self.documentDirectory mode:ArtDatabaseModeWrite];
}

#pragma mark - 创建更新表
- (NSInteger)getCurrentDBVersion
{
    return 6;
}

- (void)createAllTable:(FMDatabase *)aDB{
    [self.provinceTable createTable:aDB];
}

- (void)updateDB:(FMDatabase *)aDB{
    
    [self.provinceTable updateDB:aDB];
}

#pragma make - 懒加载
- (NSString *)documentDirectory{
    if (!_documentDirectory) {

        NSString *filename = @"HaloShop.db";
        _documentDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];

    }
    return _documentDirectory;
}

- (ProvinceTable *)provinceTable
{
    if (!_provinceTable) {
        _provinceTable = [[ProvinceTable alloc] init];
        _provinceTable.dbQueue = self.dbQueue;
    }
    return _provinceTable;
}

@end
