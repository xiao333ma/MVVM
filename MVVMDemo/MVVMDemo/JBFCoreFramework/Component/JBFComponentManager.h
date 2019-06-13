//
//  JBFComponentManager.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const JBFComponentPlaceholderName;

@class JBFComponentConfig;

@protocol JBFComponentRegisterProtocol <NSObject>

@required
- (NSString *)componentName;
+ (NSDictionary<NSString *, JBFComponentConfig *> *)createComNameKeyAndComConfigObj;

@optional

- (Class)whichJBFWebViewControllerClassOpenH5;

@end

__attribute__((objc_subclassing_restricted))
@interface JBFComponentManager : NSObject

+ (instancetype)defaultManager;

/**
 register a class become a Component
 must call the method in +(void)load
 superClass had registed subclass not need register
 
 @param obj Class conforms the <JBFComponentRegisterProtocol>
 */
- (void)registerComponentWithClazz:(Class<JBFComponentRegisterProtocol>)obj;

@end
