//
//  ProvinceTable.m
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "ProvinceTable.h"

@implementation ProvinceTable

- (void)configTableName{
    
    self.contentClass = [CityModel class];
    self.tableName = @"wtw_regions";
}

- (NSString *)contentId{
    return @"code";
}

- (NSArray<NSString *> *)getContentField{
    
    return @[@"code",@"name"];
    
}

- (BOOL)enableCache{
    return NO;
}


@end
