//
//  NSObject+KVO.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXTKeyPathCoding.h"

/**
 *  A macro for Observing an object's property
 *
 *  We recommand use this macro to observe an object's property change and 
 *  then call the handle method, for example:
 *
 *  [[JBFObserve(user, name)] handle:^(id newValue) {
 *      NSLog(@"%@", newValue)
 *  }];
 *
 *  @param TARGET  observed object
 *  @param KEYPATH property's keypath
 */
#define JBFObserve(TARGET, KEYPATH) [self observe:(id)(TARGET) forKeyPath:@keypath(TARGET, KEYPATH)]

typedef void (^JBFKVOHandleBlock)(id newValue);

/**
 *  KVO Category for NSObject
 */
@interface NSObject (KVO)

/**
 *  observe an object's property
 *
 *  @param observedObject observed object
 *  @param keyPath        key path for the property
 *  @param handler        handler callback when property changed
 */
- (void)observe:(NSObject *)observedObject forKeyPath:(NSString *)keyPath handler:(JBFKVOHandleBlock)handler;

/**
 *  observe an object's property
 *
 *  @param observedObject observed object
 *  @param keyPath        key path for the property
 */
- (id)observe:(NSObject *)observedObject forKeyPath:(NSString *)keyPath;

/**
 *  handle callback when observed object's property changed
 *
 *  @param handler handler callback
 */
- (void)handle:(JBFKVOHandleBlock)handler;

@end
