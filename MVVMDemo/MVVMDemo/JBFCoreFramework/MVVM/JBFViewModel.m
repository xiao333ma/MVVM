//
//  JBFViewModel.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFViewModel.h"
#import "JBFPipeline.h"

@interface JBFViewModel ()
@end

#pragma mark - JBFViewModel implementation

@implementation JBFViewModel

- (instancetype)initWithContext:(NSDictionary *)context {
    
    self = [super init];
    if (self) {
        _context = context;
        [self prepare];
        [self addObservers];
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", self.class);
}
#endif

#pragma mark - JDStore Protocol

- (void)prepare {

}

- (void)addObservers {
    
}

- (JBFPipeline *)pipeline {
    NSCAssert(0, @"该协议只能在子类中实现，父类中不能实现");
    return nil;
}

- (NSDictionary *)contextForTransition {
    NSCAssert(0, @"该协议只能在子类中实现，父类中不能实现");
    return nil;
}

- (void)fetchData {
    
}

@end
