//
//  PlayRecordTable.m
//  HBCollege
//
//  Created by 周德艺 on 16/9/19.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import "PlayRecordTable.h"
#import "PlayRecordModel.h"

@implementation PlayRecordTable

- (void)configTableName{
    
    self.contentClass = [PlayRecordModel class];
    self.tableName = @"PlayRecordTable";
}

- (NSString *)contentId{
    return @"record_id";
}

- (NSArray<NSString *> *)getContentField{
    return @[@"record_id",@"record_percent"];
}

- (BOOL)enableCache{
    return NO;
}


@end
