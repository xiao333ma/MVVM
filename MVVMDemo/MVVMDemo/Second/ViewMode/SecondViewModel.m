//
//  SecondViewModel.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "SecondViewModel.h"
#import "SecondPipeline.h"

@interface SecondViewModel ()

@property (nonatomic, strong) SecondPipeline *pipeline;

@end

@implementation SecondViewModel

- (instancetype)initWithContext:(NSDictionary *)context {
    if (self = [super initWithContext:context]) {
        self.pipeline.originStr = self.context[@"str"];
    }
    return self;
}

- 

- (void)addObservers {
    
}

- (SecondPipeline *)pipeline {
    if (!_pipeline) {
        _pipeline = [[SecondPipeline alloc] init];
    }
    return _pipeline;
}

@end
