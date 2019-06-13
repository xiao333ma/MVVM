//
//  HomeViewModel.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomeViewModel.h"
#import "HomePipeline.h"

@interface HomeViewModel ()

@property(nonatomic, strong)HomePipeline *pipeline;

@end

@implementation HomeViewModel

- (instancetype)initWithContext:(NSDictionary *)context {
    if (self = [super initWithContext:context]) {
        [self fetchData];
    }
    return self;
}

- (void)fetchData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            NSString *str = @"";
            if (i % 2 == 0) {
                str = @"test.jpg";
            } else {
                str = [NSString stringWithFormat:@"title --- %d", i];
            }
            [array addObject:str];
        }
        self.pipeline.homeModel.dataArray = [array mutableCopy];
    });
}

- (NSDictionary *)contextForTransition {
    
    return nil;
}

- (HomePipeline *)pipeline {
    if (!_pipeline) {
        _pipeline = [[HomePipeline alloc] init];
    }
    return _pipeline;
}

@end
