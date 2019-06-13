//
//  NSObject+Associate.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "NSObject+Associate.h"
#import <objc/runtime.h>

@implementation NSObject (Associate)

- (void)jbf_setAssociateObject:(id)object forKey:(NSString *)key {
    
    if (!key) {
        return;
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)(key), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)jbf_associateObjectForKey:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

@end
