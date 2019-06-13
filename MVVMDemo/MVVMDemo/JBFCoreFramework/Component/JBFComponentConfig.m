//
//  JBFComponentConfig.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFComponentConfig.h"
#import <objc/runtime.h>

@interface JBFComponentConfig()
@end

@implementation JBFComponentConfig
@synthesize className = _className;

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

#pragma mark - impl

+ (instancetype)quickInitComponent {
    JBFComponentConfig *componentConfig = [[JBFComponentConfig alloc] init];
    return componentConfig;
}

@end

const char * JBFComponentConfig_p_storeClassName = "JBFComponentConfig_p_storeClassName";
const char * JBFComponentConfig_p_viewClassName = "JBFComponentConfig_p_viewClassName";
const char * JBFComponentConfig_p_mvcsAbility = "JBFComponentConfig_p_mvcsAbility";

@implementation JBFComponentConfig (MVVM)

+ (instancetype)quickInitComponentWithViewModelClassName:(NSString *)viewModelClassName
                                       viewClassName:(NSString *)viewClassName {
    JBFComponentConfig *config = [self quickInitComponent];
    config.viewModelClassName = viewModelClassName;
    config.viewClassName = viewClassName;
    config.mvvmAbility = YES;
    return config;
}

+ (instancetype)doNotNeedMVVMAbilityComponent {
    JBFComponentConfig *config = [self quickInitComponent];
    config.mvvmAbility = NO;
    return config;
}

#pragma mark - override getter setter

- (void)setMvvmAbility:(BOOL)mvvmAbility {
     objc_setAssociatedObject(self, &JBFComponentConfig_p_mvcsAbility,[NSNumber numberWithBool:mvvmAbility], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mvvmAbility {
    NSNumber *num = objc_getAssociatedObject(self, &JBFComponentConfig_p_mvcsAbility);
    if (num == nil) {
        return NO;
    } else {
        return [num boolValue];
    }
}

- (void)setViewClassName:(NSString *)viewClassName {
    objc_setAssociatedObject(self, &JBFComponentConfig_p_viewClassName, viewClassName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)viewClassName {
    return objc_getAssociatedObject(self, &JBFComponentConfig_p_viewClassName);
}


- (void)setViewModelClassName:(NSString *)viewModelClassName {
    objc_setAssociatedObject(self, &JBFComponentConfig_p_storeClassName, viewModelClassName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)viewModelClassName {
    return objc_getAssociatedObject(self, &JBFComponentConfig_p_storeClassName);
}

@end
