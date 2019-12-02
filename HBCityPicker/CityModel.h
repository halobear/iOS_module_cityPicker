//
//  CityModel.h
//  HaloShop
//
//  Created by monkey on 16/5/17.
//  Copyright © 2016年 ymonke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSData

@property(nonatomic,strong)NSString *level;
@property(nonatomic,strong)NSString *code;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *parent_id;
@property(nonatomic,strong)NSString *sort_order;


//城市选择
@property (nonatomic, copy) NSString *pinYin;

@property (nonatomic, copy) NSString *pinYinHead;

@property (nonatomic, strong) NSArray *districts;

@end

