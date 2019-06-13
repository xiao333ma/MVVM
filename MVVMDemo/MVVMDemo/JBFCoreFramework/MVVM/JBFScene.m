//
//  JBFScene.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFScene.h"
#import "JBFBaseViewController.h"
#import "NSObject+KVO.h"
#import <objc/runtime.h>

@interface JBFScene()
@property (nonatomic,strong)NSPointerArray *weakControllers;
@end

@implementation JBFScene

#pragma  mark - init
- (instancetype)init {
    self = [super init];
    if(self != nil){
        _weakControllers = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", self.class);
}
#endif

#pragma mark - private
- (void)jd_addController:(JBFBaseViewController *)vc {
    if (![vc isKindOfClass:[JBFBaseViewController class]]) {
        NSAssert(NO, @"%@ 不是JBFBaseViewController的子类",vc);
    }else{
        if (![[self.weakControllers allObjects] containsObject:vc]) {
             [self.weakControllers addPointer:(__bridge void *)(vc)];
        }
        if (self.weakControllers.count == 1) {
            [self jd_observer];
        }
    }
}

- (void)jd_removeController:(JBFBaseViewController *)vc {
    if (![vc isKindOfClass:[JBFBaseViewController class]]) {
        NSAssert(NO, @"%@ 不是JBFBaseViewController的子类",vc);
    }else{
        if ([[self.weakControllers allObjects] containsObject:vc]) {
            [self.weakControllers removePointerAtIndex:[[self.weakControllers allObjects] indexOfObject:vc]];
        }
    }
}





- (void)jd_observer {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s",property_getName(property)];
        if (propertyName.length > 0) {
            __weak id wself = self;
            [self observe:self forKeyPath:propertyName handler:^(id newValue) {
                JBFScene *sself = wself;
                if (sself.weakControllers.count > 1) {
                     [sself jd_propertyChange];
                }
            }];
        }
    }
    free(properties);
}

- (void)jd_propertyChange {
    [[self.weakControllers allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[JBFBaseViewController class]] && [obj respondsToSelector:@selector(changeFromScene:)]) {
            [obj changeFromScene:self];
        }
    }];
}

@end
