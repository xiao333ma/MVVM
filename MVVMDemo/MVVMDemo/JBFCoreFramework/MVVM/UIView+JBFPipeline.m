//
//  UIView+JDPipeline.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "UIView+JBFPipeline.h"
#import <objc/runtime.h>
#import <objc/message.h>

const char* UIView_p_JBFViewPipeline = "UIView_p_JBFViewPipeline";

@implementation UIView (JBFViewPipeline)

- (void)setPipeline:(JBFPipeline *)pipeline {
    objc_setAssociatedObject(self, &UIView_p_JBFViewPipeline, pipeline, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(setupSubViewsPipline:)]) {
       ((void(*)(id, SEL, id))objc_msgSend)(self, @selector(setupSubViewsPipline:), pipeline);
    }
    
    if ([self respondsToSelector:@selector(addObservers)]) {
        [self performSelector:@selector(addObservers)];
    }
  #pragma clang diagnostic pop
}

- (JBFPipeline *)pipeline {
    return objc_getAssociatedObject(self, &UIView_p_JBFViewPipeline);
}

#pragma maek - JBFViewPipelineInterface

- (void)addObservers {
    NSCAssert(0, @"该协议只能在具体的业务View中被实现");
}

@end
