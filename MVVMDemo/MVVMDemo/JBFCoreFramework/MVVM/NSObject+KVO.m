//
//  NSObject+KVO.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "NSObject+KVO.h"
#import "NSObject+Dealloc.h"
#import "NSObject+Associate.h"
#import <objc/runtime.h>

static NSString * const kJBFKVOInfoskey = @"kJBFKVOInfoskey";

#pragma mark - _JDKVOInfo

/**
 *  _JBFKVOInfo class
 *
 *  This is a private class for the basic informations of a KVO
 */
@interface __JBFKVOInfo : NSObject

@property (nonatomic, unsafe_unretained) NSObject *observedObject;
@property (nonatomic, unsafe_unretained) NSObject *observingObject;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) JBFKVOHandleBlock handler;

@end

@implementation __JBFKVOInfo

@end

#pragma mark - NSObject (KVO)

@implementation NSObject (KVO)

- (void)observe:(NSObject *)observedObject forKeyPath:(NSString *)keyPath handler:(JBFKVOHandleBlock)handler {
    
    if (!observedObject) {
        return;
    }
    
    __JBFKVOInfo *info = [self jd_createKVOInfoWithObserved:observedObject forKeyPath:keyPath handler:handler];
    [self jd_registerKVOWithInfo:info];
}

- (id)observe:(NSObject *)observedObject forKeyPath:(NSString *)keyPath {
    
    if (!observedObject) {
        return nil;
    }
    
    __JBFKVOInfo *info = [self jd_createKVOInfoWithObserved:observedObject forKeyPath:keyPath handler:nil];
    [self jd_registerKVOWithInfo:info];
    return info;
}

- (void)handle:(JBFKVOHandleBlock)handler {
    
    if ([self isKindOfClass:[__JBFKVOInfo class]]) {
        __JBFKVOInfo *info = (__JBFKVOInfo *)self;
        info.handler = handler;
    }
}

#pragma mark - Private

- (__JBFKVOInfo *)jd_createKVOInfoWithObserved:(NSObject *)observedObject forKeyPath:(NSString *)keyPath handler:(JBFKVOHandleBlock)handler {
    
    if (!observedObject) {
        return nil;
    }
    
    __JBFKVOInfo *info = [[__JBFKVOInfo alloc] init];
    info.observedObject = observedObject;
    info.keyPath = keyPath;
    info.handler = handler;
    info.observingObject = self;
    return info;
}

- (void)jd_registerKVOWithInfo:(__JBFKVOInfo *)info {
    
    if (!info) {
        return;
    }
    
    // 将待监听的消息绑定到观察者上
    [self jd_kvo_bindKVOInfo:info withObject:self];
    
    // 若被观察者跟观察者不是同一个对象，则还需将待监听的消息绑定到被观察者上
    if (info.observedObject != self) {
        [self jd_kvo_bindKVOInfo:info withObject:info.observedObject];
    }
    
    // 建立被观察者与观察者之间的kvo关系
    [info.observedObject addObserver:self
                          forKeyPath:info.keyPath
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                             context:(__bridge void *)(info)];
}

- (void)jd_kvo_bindKVOInfo:(__JBFKVOInfo *)info withObject:(NSObject *)targetObject {
    if (!info || !targetObject) {
        return;
    }
    
    // 将当前注册的kvo信息存放到指定对象的kvo信息列表中
    NSMutableArray *infos = [targetObject jbf_associateObjectForKey:kJBFKVOInfoskey];
    if (!infos) {
        infos = [[NSMutableArray alloc] init];
        [targetObject jbf_setAssociateObject:infos forKey:kJBFKVOInfoskey];
    }
    [infos addObject:info];
    
    // 在当前对象释放之前，需先解除与其相关联的所有kvo
    [self yq_kvo_registerDeallocHandleForObject:targetObject];
}

- (void)yq_kvo_registerDeallocHandleForObject:(NSObject *)targetObject {
    __unsafe_unretained NSObject *registeredObject = targetObject;
    [registeredObject registerDeallocHandleWithKey:@"jbf_dealloc_kvoHandle" handle:^{
        
        NSArray *infos = [registeredObject jbf_associateObjectForKey:kJBFKVOInfoskey];
        [infos enumerateObjectsUsingBlock:^(__JBFKVOInfo *info, NSUInteger idx, BOOL *stop) {
            // 移除kvo
            [info.observedObject removeObserver:info.observingObject forKeyPath:info.keyPath];
            
            // 同时需要将当前kvo关联从KVO链中的另一个对象的kvo关联列表中移除
            NSObject *otherObject = nil;
            if (info.observedObject != registeredObject) {
                otherObject = info.observedObject;
            } else if (info.observingObject != registeredObject) {
                otherObject = info.observingObject;
            }
            
            NSMutableArray *infosForOtherObject = [otherObject jbf_associateObjectForKey:kJBFKVOInfoskey];
            [infosForOtherObject removeObject:info];
        }];
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    __JBFKVOInfo *info = (__bridge __JBFKVOInfo *)(context);
    if (info.handler) {
        id changedValue = [change valueForKey:NSKeyValueChangeNewKey];
        info.handler([changedValue isKindOfClass:[NSNull class]] ? nil : changedValue);
    }
}

@end
