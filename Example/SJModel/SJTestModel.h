//
//  SJTestModel.h
//  SJModel
//
//  Created by SDPMobile on 2017/10/24.
//  Copyright © 2017年 superzhaolong@126.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJUserModel.h"

@interface SJTestModel : NSObject
@property (nonatomic, copy) NSString *test0;
@property (nonatomic, assign) NSInteger test1;
@property (nonatomic, strong) NSNumber *test2;
@property (nonatomic, assign) BOOL test3;
@property (nonatomic, strong) SJUserModel *user;
@end
