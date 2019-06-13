//
//  NSObject+Dealloc.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "NSObject+Dealloc.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const void *kNSObjectWillDeallocBlockKey = &kNSObjectWillDeallocBlockKey;    //!< Key for associated object

/**
 *  Create a NSMutableSet instance to store the name of the class which want to 
 *  change the dealloc method's implementation.
 *
 *  @return NSMutableSet object. The return value is a static instance, we just create this instance 
 *          once in the whole lifetime of the app.
 */
static NSMutableSet *swizzledClasses() {
    
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    return swizzledClasses;
}

static void swizzleDeallocIfNeeded(Class classToSwizzle) {
    
    @synchronized (swizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([swizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            
            NSDictionary *handleDic = objc_getAssociatedObject(self, kNSObjectWillDeallocBlockKey);
            [handleDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                void(^willDeallocHandle)() = obj;
                willDeallocHandle();
            }];
            
            objc_setAssociatedObject(self, kNSObjectWillDeallocBlockKey, nil, OBJC_ASSOCIATION_ASSIGN);
            
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [swizzledClasses() addObject:className];
    }
}

@implementation NSObject (Dealloc)

- (void)registerDeallocHandleWithKey:(NSString *)handleKey handle:(JBFDeallocBlock)willDeallocHandle {
    
    @synchronized(self) {
        if (!handleKey || !willDeallocHandle) {
            return;
        }
        
        NSMutableDictionary *handleDic = objc_getAssociatedObject(self, kNSObjectWillDeallocBlockKey);
        if (!handleDic) {
            handleDic = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, kNSObjectWillDeallocBlockKey, handleDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        handleDic[handleKey] = willDeallocHandle;
        
        swizzleDeallocIfNeeded([self class]);
    }
}

@end
