//
//  NSObject+SJModel.m
//  JsonToModelDemo
//
//  Created by SDPMobile on 2017/10/23.
//  Copyright © 2017年 SoulJa. All rights reserved.
//

#import "NSObject+SJModel.h"
#import <objc/message.h>

static NSString * const SJClassType_object = @"对象类型";
static NSString * const SJClassType_basic = @"基础数据类型";
static NSString * const SJClassType_other = @"其他";

@implementation NSObject (SJModel)
#pragma mark - 字典转模型
+ (instancetype)sj_initWithDictionary:(NSDictionary *)dict {
    // 创建类
    id object = [[self alloc] init];
    
    unsigned int outCount = 0;
    
    //获取属性列表
    objc_property_t *arrPropertys = class_copyPropertyList([object class], &outCount);
    
    // 循环遍历
    for (int i = 0; i < outCount; i++) {
        // 取出单个属性
        objc_property_t property = arrPropertys[i];
        // 获取属性名
        NSString *propertyKey = [NSString stringWithUTF8String:property_getName(property)];
        // 字典中的属性名
        NSString *newPropertyKey;
        // 是否替换了属性名
        if ([self respondsToSelector:@selector(sj_propertykeyReplacedWithValue)]) {
            newPropertyKey = [[self sj_propertykeyReplacedWithValue] objectForKey:propertyKey];
        }
        if (!newPropertyKey) {
            newPropertyKey = propertyKey;
        }
        
        NSLog(@"属性名:%@", propertyKey);
        
        // 获取属性值
        id propertyValue = [dict objectForKey:newPropertyKey];
        // 返回数据为nil
        if (propertyValue == nil) {
            continue;
        }
        // 获取属性类型
        NSDictionary *dicPropertyType = [self propertyTypeWithProperty:property];
        NSString *propertyClassType = [dicPropertyType objectForKey:@"classType"];
        NSString *propertyType = [dicPropertyType objectForKey:@"type"];
        
        // 对象属性类型
        if ([propertyType isEqualToString:SJClassType_object]) {
            // 数组类型
            if ([propertyClassType isEqualToString:@"NSArray"] || [propertyClassType isEqualToString:@"NSMutableArray"]) {
                if ([self respondsToSelector:@selector(sj_objectClassInArray)]) {
                    id propertyValueType = [[self sj_objectClassInArray] objectForKey:propertyKey];
                    if ([propertyValueType isKindOfClass:[NSString class]]) {
                        propertyValue = [NSClassFromString(propertyValueType) sj_initWithArray:propertyValue];
                    }
                    else {
                        propertyValue = [propertyValueType sj_initWithArray:propertyValue];
                    }
                    
                    if (propertyValue != nil) {
                        [object setValue:propertyValue forKey:propertyKey];
                    }
                }
                
            }
            // 字典类型   不考虑，一般不会用字典，用自定义model
            else if ([propertyClassType isEqualToString:@"NSDictionary"] || [propertyClassType isEqualToString:@"NSMutableDictionary"]) {
                
                
            }
            // 字符串类型
            else if ([propertyClassType isEqualToString:@"NSString"]) {
                if (propertyValue != nil) {
                    [object setValue:propertyValue forKey:propertyKey];
                }
            }
            // NSNumber类型
            else if ([propertyClassType isEqualToString:@"NSNumber"]) {
                if (propertyValue != nil) {
                    [object setValue:propertyValue forKey:propertyKey];
                }
            }
            // 自定义类型,循环调用，一直到不是自定义类型
            else {
                propertyValue = [NSClassFromString(propertyClassType) sj_initWithDictionary:propertyValue];
                if (propertyValue != nil) {
                    [object setValue:propertyValue forKey:propertyKey];
                }
            }
        }
        // 基础数据类型
        else if ([propertyType isEqualToString:SJClassType_basic]) {
            //bool类型
            if ([propertyClassType isEqualToString:@"c"]) {
                NSString *lowerValue = [propertyValue lowercaseString];
                if ([lowerValue isEqualToString:@"yes"] || [lowerValue isEqualToString:@"true"]) {
                    propertyValue = @(YES);
                } else if ([lowerValue isEqualToString:@"no"] || [lowerValue isEqualToString:@"false"]) {
                    propertyValue = @(NO);
                }
            }
            //bool类型
            else if ([propertyClassType isEqualToString:@"BOOL"]) {
                if ([propertyValue isKindOfClass:[NSNumber class]]) {
                    if ([propertyValue isEqual:@1]) {
                        propertyValue = @(YES);
                    } else {
                        propertyValue = @(NO);
                    }
                } else if ([propertyValue isKindOfClass:[NSString class]]) {
                    NSString *lowerValue = [propertyValue lowercaseString];
                    if ([lowerValue isEqualToString:@"yes"] || [lowerValue isEqualToString:@"true"] || [lowerValue isEqualToString:@"1"]) {
                        propertyValue = @(YES);
                    } else if ([lowerValue isEqualToString:@"no"] || [lowerValue isEqualToString:@"false"] || [lowerValue isEqualToString:@"0"]) {
                        propertyValue = @(NO);
                    }
                } else {
                    propertyValue = [[[NSNumberFormatter alloc] init] numberFromString:propertyValue];
                }
            }
            
            
            if (propertyValue != nil) {
                [object setValue:propertyValue forKey:propertyKey];
            }
        }
        // 其他类型
        else {
            if (propertyValue != nil) {
                [object setValue:propertyValue forKey:propertyKey];
            }
        }
    }
    // 释放属性列表
    free(arrPropertys);
    return object;
}

#pragma mark - 获取属性的类型
+ (NSDictionary *)propertyTypeWithProperty:(objc_property_t)property {
    // 获取属性的类型, 类似 T@"NSString",C,N,V_name    T@"UserModel",&,N,V_user
    NSString *propertyAttrs = @(property_getAttributes(property));
    
    NSMutableDictionary *dicPropertyType = [NSMutableDictionary dictionary];
    
    // 截取类型
    NSRange commonRange = [propertyAttrs rangeOfString:@","];
    NSString *propertyType = [propertyAttrs substringWithRange:NSMakeRange(1, commonRange.location - 1)];
    
    NSLog(@"属性类型:%@, %@", propertyAttrs, propertyType);
    // 对象类型
    if ([propertyType hasPrefix:@"@"] && propertyType.length > 2) {
        NSString *propertyClassType = [propertyType substringWithRange:NSMakeRange(2, propertyType.length - 3)];
        [dicPropertyType setObject:propertyClassType forKey:@"classType"];
        [dicPropertyType setObject:SJClassType_object forKey:@"type"         ];
    }
    // NSInteger类型
    else if ([propertyType isEqualToString:@"q"]) {
        [dicPropertyType setObject:@"NSInterger" forKey:@"classType"];
        [dicPropertyType setObject:SJClassType_basic forKey:@"type"];
    }
    // CGFloat类型
    else if ([propertyType isEqualToString:@"d"]) {
        [dicPropertyType setObject:@"CGFloat" forKey:@"classType"];
        [dicPropertyType setObject:SJClassType_basic forKey:@"type"];
    }
    // BOOL类型
    else if ([propertyType isEqualToString:@"c"] || [propertyType isEqualToString:@"B"]) {
        [dicPropertyType setObject:@"BOOL" forKey:@"classType"];
        [dicPropertyType setObject:SJClassType_basic forKey:@"type"];
    }
    // 其他
    else {
        [dicPropertyType setObject:SJClassType_other forKey:@"type"];
    }
    return dicPropertyType;
}

#pragma mark - 数组转模型数组，现在还用不了，因为还没有方法知道数组中保存的是什么类型，后面会处理
+ (instancetype)sj_initWithArray:(NSArray *)arr {
    NSAssert([arr isKindOfClass:[NSArray class]], @"不是数组");
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [modelArray addObject:[self sj_initWithArray:obj]];
        } else {
            id model = [self sj_initWithDictionary:obj];
            [modelArray addObject:model];
        }
    }];
    
    return modelArray;
}
@end
