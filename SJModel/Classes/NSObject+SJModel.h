//
//  NSObject+SJModel.h
//  JsonToModelDemo
//
//  Created by SDPMobile on 2017/10/23.
//  Copyright © 2017年 SoulJa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SJModelProtocol <NSObject>

@optional
/**
 *  数组中存储的类型
 *
 *  @return key --- 属性名,  value --- 数组中存储的类型
 */
+ (NSDictionary *)sj_objectClassInArray;

/**
 *  替换一些字段
 *
 *  @return key -- 模型中的字段， value --- 字典中的字段
 */
+ (NSDictionary *)sj_propertykeyReplacedWithValue;

@end

@interface NSObject (SJModel) <SJModelProtocol>
/*
 *  字典转模型
 *  @param  dict    字典
 */
+ (instancetype)sj_initWithDictionary:(NSDictionary *)dict;

/*
 *  数组转模型
 *  @param  arr    数组
 */
+ (instancetype)sj_initWithArray:(NSArray *)arr;
@end
