//
//  CityTable.m
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "CityTable.h"

@implementation CityTable

- (void)configTableName{
    
    self.contentClass = [CityModel class];
    self.tableName = @"CityTable";
}

- (NSString *)contentId{
    return @"region_id";
}

- (NSArray<NSString *> *)getContentField{
    
    return @[@"region_id",@"region_code",@"region_name",@"parent_id",@"sort_order"];
    
}

- (BOOL)enableCache{
    return NO;
}


@end
