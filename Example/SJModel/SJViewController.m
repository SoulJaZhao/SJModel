//
//  SJViewController.m
//  SJModel
//
//  Created by superzhaolong@126.com on 10/24/2017.
//  Copyright (c) 2017 superzhaolong@126.com. All rights reserved.
//

#import "SJViewController.h"
#import <SJModel/SJModel.h>
#import "SJTestModel.h"

@interface SJViewController ()

@end

@implementation SJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSDictionary *testDict = @{
                           @"test0"     :       @"test0",
                           @"test1"     :       @20,
                           @"test2"     :       @50,
                           @"test3"     :       @1,
                           @"user"      :       @{
                                        @"name" :   @"jim",
                                        @"age"  :   @18
                                   }
                           };
    SJTestModel *model = [SJTestModel sj_initWithDictionary:testDict];
    
    NSLog(@"test0:%@,test1:%ld,test2:%@,test3:%d,user.name:%@,user.age:%ld",model.test0,(long)model.test1,model.test2,model.test3,model.user.name,model.user.age);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
