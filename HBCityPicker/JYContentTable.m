//
//  JYContentTable.m
//  JYDatabase - OC
//
//  Created by weijingyun on 16/5/9.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYContentTable.h"
#import <UIKit/UIKit.h>
#import "FMDB.h"
#import <objc/runtime.h>

#define kAttributeArray @[@"TB",@"Td",@"Tf",@"Ti",@"Tq",@"TQ",@"T@\"NSMutableString\"",@"T@\"NSString\"",@"T@\"NSData\"",@"T@\"UIImage\""]
#define kTypeArray      @[@"BOOL",@"DOUBLE",@"FLOAT",@"INTEGER",@"INTEGER",@"INTEGER",@"VARCHAR",@"VARCHAR",@"BLOB",@"BLOB"]
#define kLenghtArray    @[@"1"   ,@"10"    ,@"10"   ,@"10"     ,@"10"     ,@"10"     ,@"128"    ,@"128",    @"256",@"256"]
@interface JYContentTable()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation JYContentTable

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configTableName];
        if ([self enableCache]) {
            self.cache = [[NSCache alloc] init];
            self.cache.countLimit = 20;
        }
    }
    return self;
}

- (void)configTableName{
    
}

- (void)insertDefaultData:(FMDatabase *)aDb{
    
}

- (BOOL)enableCache{
    return YES;
}

- (NSDictionary*)fieldLenght{
    return nil;
}

- (NSString *)contentId{
    return nil;
}

- (NSArray<NSString *> *)getContentField{
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    unsigned int outCount;
    NSLog(@"%@",NSStringFromClass(self.contentClass));
    objc_property_t *properties = class_copyPropertyList(self.contentClass, &outCount);
    for (NSInteger index = 0; index < outCount; index++) {
        NSString *tmpName = [NSString stringWithFormat:@"%s",property_getName(properties[index])];
        NSString* prefix = @"DB";
        if ([tmpName hasSuffix:prefix]) {
            [arrayM addObject:tmpName];
        }
    }
    
    if (properties) {
        free(properties);
    }
    
    NSAssert([self contentId].length > 0, @"主键不能为空");
    [arrayM removeObject:[self contentId]];
    return [arrayM copy];
}

#pragma mark - field Attributes 获取准备处理 如 personid varchar(64)
- (NSDictionary*)attributeTypeDic{
    NSMutableDictionary *dicM = [[NSMutableDictionary alloc] init];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(self.contentClass, &outCount);
    for (NSInteger index = 0; index < outCount; index++) {
        NSString *tmpName = [NSString stringWithFormat:@"%s",property_getName(properties[index])];
        NSString *tmpAttributes = [NSString stringWithFormat:@"%s",property_getAttributes(properties[index])];
        NSArray<NSString*> *attributes = [tmpAttributes componentsSeparatedByString:@","];
        dicM[tmpName] = attributes.firstObject;
    }
    
    if (properties) {
        free(properties);
    }
    return [dicM copy];
}

// 类型的映射
- (NSArray *)conversionAttributeType:(NSString *)aType{
    NSInteger index = [kAttributeArray indexOfObject:aType];
    NSAssert(index <= kAttributeArray.count, @"当前类型不支持");
    NSString *str = kTypeArray[index];
    NSString *length = kLenghtArray[index];
    return @[str,length];
}

#pragma mark - 查询的处理函数
- (void)checkError:(FMDatabase *)aDb
{
    if ([aDb hadError]) {
        NSLog(@"DB Err %d: %@", [aDb lastErrorCode], [aDb lastErrorMessage]);
    }
}

// 数据预处理
- (id)checkEmpty:(id)aObject
{
    @autoreleasepool {
        if ([aObject isKindOfClass:[UIImage class]]) {
            aObject = UIImageJPEGRepresentation(aObject,1.0);
        }
        return aObject == nil ? [NSNull null] : aObject;
    }
}

// 查询出来的数据处理
- (id)checkVaule:(id)aVaule forKey:(NSString*)aKey{
    @autoreleasepool {
        NSString *type = [self attributeTypeDic][aKey];
        if ([type  isEqual: @"T@\"UIImage\""] && aVaule != [NSNull null]) {
            aVaule = [UIImage imageWithData:aVaule];
        }
        return aVaule;
    }
}

#pragma mark - Create Table
- (void)createTable:(FMDatabase *)aDB{
    [self configTableName];
    NSDictionary * typeDict = [self attributeTypeDic];
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendFormat:@"CREATE TABLE if not exists %@ (%@ varchar(64) NOT NULL, ",self.tableName,[self contentId]];
    [[self getContentField] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = [self conversionAttributeType:typeDict[obj]];
        NSString *lenght = [self fieldLenght][obj] == nil ? array.lastObject : [self fieldLenght][obj];
        [strM appendFormat:@"%@ %@(%@), ",obj,array.firstObject,lenght];
    }];
    [strM appendFormat:@"PRIMARY KEY (%@) ON CONFLICT REPLACE)",[self contentId]];
    NSLog(@"----------%@",strM);
    [aDB executeUpdate:[strM copy]];
    [self checkError:aDB];
    
    // 插入默认数据
    [self insertDefaultData:aDB];
}

#pragma mark - Upgrade
- (void)updateDB:(FMDatabase *)aDB fromVersion:(NSInteger)aFromVersion toVersion:(NSInteger)aToVersion {
    NSAssert(NO, @"需要在子类重写该方法，建议使用 - (void)updateDB:(FMDatabase *)aDB 升级");
}

- (void)updateDB:(FMDatabase *)aDB{
    [self configTableName];
    NSArray<NSString *> *tablefields = [self getCurrentFields:aDB];
    NSArray<NSString *> *contentfields = [self getContentField];
    __block NSMutableArray *addfields = [contentfields mutableCopy];
    [addfields addObject:[self contentId]];
    __block NSMutableArray *minusfields = [tablefields mutableCopy];
    [tablefields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [addfields removeObject:obj];
    }];
    
    [minusfields removeObject:[self contentId]];
    [contentfields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [minusfields removeObject:obj];
    }];
    [self updateDB:aDB addFieldS:addfields];
    [self updateDB:aDB minusFieldS:minusfields];
}

- (NSArray<NSString*> *)getCurrentFields:(FMDatabase *)aDB{
    __block NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info([%@])", self.tableName];
    FMResultSet *rs = [aDB executeQuery:sql];
    while([rs next]) {
        [arrayM addObject:[rs stringForColumn:@"name"]];
    }
    [rs close];
    [self checkError:aDB];
    return arrayM;
}

// 新增字段数组
- (void)updateDB:(FMDatabase *)aDB addFieldS:(NSArray<NSString*>*)aFields{
    NSDictionary * typeDict = [self attributeTypeDic];
    [aFields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = [self conversionAttributeType:typeDict[obj]];
        NSString *lenght = [self fieldLenght][obj] == nil ? array.lastObject : [self fieldLenght][obj];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@(%@)", self.tableName,obj,array.firstObject,lenght];
        [aDB executeUpdate:sql];
        [self checkError:aDB];
    }];
}

// 删除字段 因为sqlLite没有提供类似ADD的方法，我们需要新建一个表然后删除原表
- (void)updateDB:(FMDatabase *)aDB minusFieldS:(NSArray<NSString*>*)aFields{
    if (aFields.count <= 0) {
        return;
    }
    NSLog(@"多余字段%@",aFields);
    // 1.根据原表新建一个表
    NSString *tempTableName = [NSString stringWithFormat:@"temp_%@",self.tableName];
    __block NSMutableString *tableField = [[NSMutableString alloc] init];
    [[self getContentField] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tableField appendFormat:@",%@",obj];
    }];
    NSString *sql = [NSString stringWithFormat:@"create table %@ as select %@%@ from %@", tempTableName,[self contentId],tableField,self.tableName];
    [aDB executeUpdate:sql];
    [self checkError:aDB];
    // 2.删除原表
    sql = [NSString stringWithFormat:@"drop table if exists %@", self.tableName];
    [aDB executeUpdate:sql];
    [self checkError:aDB];
    
    // 3.将tempTableName 该名为 table
    sql = [NSString stringWithFormat:@"alter table %@ rename to %@",tempTableName ,self.tableName];
    [aDB executeUpdate:sql];
    [self checkError:aDB];
    
    // 4.为新表添加唯一索引
    sql = [NSString stringWithFormat:@"create unique index '%@_key' on  %@(%@)", self.tableName,self.tableName,[self contentId]];
    [aDB executeUpdate:sql];
    [self checkError:aDB];
}

#pragma mark - insert 插入
- (void)insertDB:(FMDatabase *)aDB contents:(NSArray *)aContents{
    [self configTableName];
    NSLog(@"insert %@",[aContents.firstObject class]);
    NSArray<NSString *> *fields = [self getContentField];
    // 1.插入语句拼接
    NSMutableString *strM = [[NSMutableString alloc] init];
    NSMutableString *strM1 = [[NSMutableString alloc] initWithString:@"?"];
    [strM appendFormat:@"INSERT OR REPLACE INTO %@(%@",self.tableName,[self contentId]];
    [fields enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@", %@",obj];
        [strM1 appendFormat:@",?"];
    }];
    [strM appendFormat:@") VALUES (%@)",strM1];
    NSLog(@"-----%@",strM);
        
    // 2.一条条插入
    [aContents enumerateObjectsUsingBlock:^(id  _Nonnull aContent, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 断言消息 主key 不能为空
        NSString * ts = [NSString stringWithFormat:@"%@不能为空",[self contentId]];
        NSAssert([aContent valueForKey:[self contentId]], ts );

        // 2.1 获取参数
        NSMutableArray *arrayM = [[NSMutableArray alloc] init];
        [arrayM addObject:[aContent valueForKey:[self contentId]]];
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arrayM addObject:[self checkEmpty:[aContent valueForKey:obj]]];
        }];
        
        // 2.2 执行插入
        [aDB executeUpdate:[strM copy] withArgumentsInArray:[arrayM copy]];
        [self saveCacheContent:aContent];
    }];
    
    [self checkError:aDB];
}

- (void)insertContent:(id)aContent{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [self insertDB:db contents:@[aContent]];
    }];
}

- (void)insertContents:(NSArray *)aContents{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [self insertDB:db contents:aContents];
    }];
}

#pragma mark - update 更新
- (void)updateDB:(FMDatabase *)aDB contents:(NSArray *)aContents{
    [self configTableName];
    NSLog(@"insert %@",[aContents.firstObject class]);
    NSArray<NSString *> *fields = [self getContentField];
    // 1.插入语句拼接
    NSMutableString *strM = [[NSMutableString alloc] init];
    NSMutableString *strM1 = [[NSMutableString alloc] initWithString:@"?"];
    [strM appendFormat:@"INSERT OR REPLACE INTO %@(%@",self.tableName,[self contentId]];
    [fields enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@", %@",obj];
        [strM1 appendFormat:@",?"];
    }];
    [strM appendFormat:@") VALUES (%@)",strM1];
    NSLog(@"-----%@",strM);
    
    // 2.一条条插入
    [aContents enumerateObjectsUsingBlock:^(id  _Nonnull aContent, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 断言消息 主key 不能为空
        NSString * ts = [NSString stringWithFormat:@"%@不能为空",[self contentId]];
        NSAssert([aContent valueForKey:[self contentId]], ts );
        
        // 2.1 获取参数
        NSMutableArray *arrayM = [[NSMutableArray alloc] init];
        [arrayM addObject:[aContent valueForKey:[self contentId]]];
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arrayM addObject:[self checkEmpty:[aContent valueForKey:obj]]];
        }];
        
        // 2.2 执行插入
        [aDB executeUpdate:[strM copy] withArgumentsInArray:[arrayM copy]];
        [self saveCacheContent:aContent];
    }];
    
    [self checkError:aDB];
}

- (void)updateContent:(id)aContent{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [self insertDB:db contents:@[aContent]];
    }];
}


- (BOOL )updateContentByConditions:(void (^)(JYQueryConditions *make))block{
    __block BOOL success = NO;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [self updateContentDB:db byconditions:block];
    }];
    return success;
}



- (BOOL)updateContentDB:(FMDatabase *)aDB byconditions:(void (^)(JYQueryConditions *make))block{
    [self configTableName];
    JYQueryConditions *conditions = [[JYQueryConditions alloc] init];
    block(conditions);
    __block NSMutableString *strM = [[NSMutableString alloc] init];
    [conditions.conditions enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"%@ %@ '%@'",obj[kField],obj[kEqual],obj[kCompare]];
       
        if (idx < conditions.conditions.count - 1) {
            [strM appendFormat:@" , "];
        }
    }];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ ",self.tableName, strM,conditions.conditionStr];
    NSLog(@"conditions -- %@",sql);

    BOOL res = [aDB executeUpdate:sql];
    if (!res) {
        NSLog(@"error to UPDATE data");
    } else {
        NSLog(@"succ to UPDATE data");
    }
    [self checkError:aDB];
    return res;
}


#pragma mark - get 查询
- (NSArray *)getContentDB:(FMDatabase *)aDB byconditions:(void (^)(JYQueryConditions *make))block{
    [self configTableName];
    JYQueryConditions *conditions = [[JYQueryConditions alloc] init];
    block(conditions);
    __block NSMutableString *strM = [[NSMutableString alloc] init];
    [conditions.conditions enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"%@ %@ %@",obj[kField],obj[kEqual],obj[kCompare]];
        if (idx < conditions.conditions.count - 1) {
            [strM appendFormat:@" AND "];
        }
    }];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ %@", self.tableName, strM,conditions.orderStr];
    NSLog(@"conditions -- %@",sql);
    
    FMResultSet *rs = [aDB executeQuery:sql];
    NSArray<NSString *> *fields = [self getContentField];
    id content = nil;
    NSMutableArray *arrayM = nil;
    while([rs next]) {
        content = [[self.contentClass alloc] init];
        id value = [rs stringForColumn:[self contentId]];
        [content setValue:value forKey:[self contentId]];
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [rs objectForKeyedSubscript:obj];
            value = [self checkVaule:value forKey:obj];
            if (value != [NSNull null]) {
                [content setValue:value forKey:obj];
            }
        }];
        if (arrayM == nil) {
            arrayM = [[NSMutableArray alloc] init];
        }
        [self saveCacheContent:content];
        [arrayM addObject:content];
    }
    [rs close];
    [self checkError:aDB];
    return [arrayM copy];
}

- (NSArray *)getDB:(FMDatabase *)aDB contentByIDs:(NSArray<NSString*>*)aIDs{
    [self configTableName];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", self.tableName, [self contentId]];
    NSLog(@"contentByID--%@",sql);
     NSArray<NSString *> *fields = [self getContentField];
     __block NSMutableArray *arrayM = nil;
    [aIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull aID, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id content = [self getCacheContentID:aID];
        if (content != nil) {
            if (arrayM == nil) {
                arrayM = [[NSMutableArray alloc] init];
            }
            [arrayM addObject:content];
        }else{
            
            FMResultSet *rs = [aDB executeQuery:sql,
                               [self checkEmpty:aID]];
            if ([rs next]) {
                id content = [[self.contentClass alloc] init];
                id value = [rs stringForColumn:[self contentId]];
                [content setValue:value forKey:[self contentId]];
                [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    id value = [rs objectForKeyedSubscript:obj];
                    value = [self checkVaule:value forKey:obj];
                    if (value != [NSNull null]) {
                        [content setValue:value forKey:obj];
                    }
                }];
                if (arrayM == nil) {
                    arrayM = [[NSMutableArray alloc] init];
                }
                [self saveCacheContent:content];
                [arrayM addObject:content];
            }
            [rs close];
        }
        
    }];
    
    [self checkError:aDB];
    return [arrayM copy];
}

- (NSArray *)getAllContent:(FMDatabase *)aDB{
    [self configTableName];
    __block id content = nil;
    NSMutableArray *arrayM = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
    NSLog(@"getAllContent--%@",sql);
    FMResultSet *rs = [aDB executeQuery:sql];
    NSArray<NSString *> *fields = [self getContentField];
    while([rs next]) {
        content = [[self.contentClass alloc] init];
        id value = [rs stringForColumn:[self contentId]];
        [content setValue:value forKey:[self contentId]];
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [rs objectForKeyedSubscript:obj];
            value = [self checkVaule:value forKey:obj];
            if (value != [NSNull null]) {
                [content setValue:value forKey:obj];
            }
        }];
        if (arrayM == nil) {
            arrayM = [[NSMutableArray alloc] init];
        }
        [self saveCacheContent:content];
        [arrayM addObject:content];
    }
    [rs close];
    [self checkError:aDB];
    return [arrayM copy];
}

- (NSArray *)getContentByConditions:(void (^)(JYQueryConditions *make))block{
    __block id contents = nil;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        contents = [self getContentDB:db byconditions:block];
    }];
    return contents;
}

- (NSArray *)getContentByIDs:(NSArray<NSString*>*)aIDs{
    __block id contents = nil;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        contents = [self getDB:db contentByIDs:aIDs];
    }];
    return contents;
}

- (id)getContentByID:(NSString*)aID{
    __block id content = nil;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        content = [self getDB:db contentByIDs:@[aID]].firstObject;
    }];
    return content;
}

- (NSArray *)getAllContent{
    __block NSArray *array = nil;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        array = [self getAllContent:db];
    }];
    return array;
}
    
#pragma mark - delete 删除
- (void)deleteDB:(FMDatabase *)aDB contentByIDs:(NSArray<NSString*>*)aIDs{
    [self configTableName];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", self.tableName, [self contentId]];
    NSLog(@"delete--%@",sql);
    [aIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull aID, NSUInteger idx, BOOL * _Nonnull stop) {
        [aDB executeUpdate:sql,
        [self checkEmpty:aID]];
        [self removeCacheContentID:aID];
    }];
    [self checkError:aDB];
}

- (void)deleteAllContent:(FMDatabase *)aDB{
    [self configTableName];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", self.tableName];
    [aDB executeUpdate:sql];
    NSLog(@"delete--%@",sql);
    [self removeAllCache];
    [self checkError:aDB];
}

- (void)deleteContentByID:(NSString *)aID{
    [self.dbQueue inDatabase:^(FMDatabase *aDB) {
        [self deleteDB:aDB contentByIDs:@[aID]];
    }];
}

- (void)deleteContentByIDs:(NSArray<NSString *>*)aIDs{
    [self.dbQueue inDatabase:^(FMDatabase *aDB) {
        [self deleteDB:aDB contentByIDs:aIDs];
    }];
}

- (void)deleteAllContent{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [self deleteAllContent:db];
    }];
}

#pragma mark - 缓存存取删
- (id)getCacheContentID:(NSString *)aID{
    if (aID.length <= 0 || ![self enableCache]) {
        return nil;
    }
    return [self.cache objectForKey:aID];
}

- (void)saveCacheContent:(id)aContent{
    if (aContent == nil || ![self enableCache]) {
        return;
    }
    [self.cache setObject:aContent forKey:[aContent valueForKey:[self contentId]]];
}

- (void)removeCacheContentID:(NSString *)aID{
    if (aID.length <= 0 || ![self enableCache]) {
        return;
    }
    [self.cache removeObjectForKey:aID];
}

- (void)removeAllCache{
    if (![self enableCache]) {
        return;
    }
    [self.cache removeAllObjects];
}

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
