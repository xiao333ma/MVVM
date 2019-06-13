//
//  JBFComponentManager.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFComponentManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JBFComponentConfig.h"

NSString * const JBFComponentPlaceholderName = @"__JBFComponentPlaceholderName";

@interface JBFComponentConfig(Private)
@property (nonatomic,strong)NSMutableDictionary *propertyMutableMap;
@end

@interface JBFComponentManager()

@property (nonatomic,strong) NSMutableDictionary <NSString *,JBFComponentConfig*> *componentConfiguration;
@property (nonatomic,strong) NSMutableSet <NSString *> *classNameSet;
@property (nonatomic,strong) NSMutableSet <Class> *hascheckedClassSet;

@end

@implementation JBFComponentManager

#pragma mark - signInstans
+ (instancetype)defaultManager {
    static JBFComponentManager *s_manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_manager = [[JBFComponentManager alloc] init];
    });
    return s_manager;
}

#pragma mark -init
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _componentConfiguration = [NSMutableDictionary dictionary];
        _classNameSet = [NSMutableSet set];
        _hascheckedClassSet = [NSMutableSet set];
    }
    return self;
}

#pragma mark - impl
- (void)registerComponentWithClazz:(Class<JBFComponentRegisterProtocol>)classObj {
    id clazz = classObj;
    NSString *className = NSStringFromClass(classObj);
    if (clazz != nil && [clazz conformsToProtocol:@protocol(JBFComponentRegisterProtocol)]) {
        BOOL flag = NO;
        for (NSString *clazzName in [[self.classNameSet objectEnumerator] allObjects]) {
            if(jd_classIsKindOfClass(clazz, NSClassFromString(clazzName))){
                flag = YES;
            }
        }
        if (!flag) {
            [self.classNameSet addObject:className];
        }
    } else {
        NSAssert(0, @"%@ 没有实现协议: JBFComponentRegisterProtocol",className);
    }
}

#pragma mark - runtime
+ (void)load {
    [JBFComponentManager defaultManager];
}

#pragma mark - runtime after
//第一步，在 main 函数执行之前把所有调用 registerComponentWithClazz 需要注册成组件的类及其子类加入全局的一个 NSSet；
__attribute__((constructor(101))) static void jd_validComponent() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        unsigned int classCount = 0;
        Class *clazzes = objc_copyClassList(&classCount);
        for (unsigned int i = 0; i < classCount; i++) {
            Class clazz = clazzes[i];
            for (NSString *className in [[[JBFComponentManager defaultManager].classNameSet objectEnumerator] allObjects]) {
                if (className.length > 0 && [className isKindOfClass:[NSString class]]) {
                    Class regClazz = NSClassFromString(className);
                    if (jd_classIsKindOfClass(clazz,regClazz)) {
                        NSString *clazzName = NSStringFromClass(clazz);
                        [[JBFComponentManager defaultManager].classNameSet addObject:clazzName];
                        if (![[JBFComponentManager defaultManager].hascheckedClassSet containsObject:clazz]) {
                            jd_checkRegisterClass(clazzName);
                            [[JBFComponentManager defaultManager].hascheckedClassSet addObject:clazz];
                        }
                    }
                }
            }
        }
        
        free(clazzes);
        [JBFComponentManager defaultManager].hascheckedClassSet = nil;
        [JBFComponentManager defaultManager].classNameSet = nil;
    });
}

//第二步，通过传入的 ClassName 检查这个类是否规范的实现了 createComNameKeyAndComConfigObj 函数；
static void jd_checkRegisterClass(NSString *classname) {
    Class clazz = NSClassFromString(classname);
    if (clazz != nil) {
        Method selfClassMethod = class_getClassMethod(clazz, @selector(createComNameKeyAndComConfigObj));
        Method superClassMethod = class_getClassMethod(class_getSuperclass(clazz), @selector(createComNameKeyAndComConfigObj));
        
        if (superClassMethod == selfClassMethod) {
            NSCAssert(0, @"#%@# 没有实现协议 createComNameKeyAndComConfigObj", classname);
        }
        
        Method selfInstanceMethod = class_getInstanceMethod(clazz, @selector(componentName));
        Method superInstanceMethod = class_getInstanceMethod(class_getSuperclass(clazz), @selector(componentName));
        
        if (superInstanceMethod == selfInstanceMethod) {
            NSCAssert(0, @"#%@# 没有实现协议 componentName", classname);
        }
        
        id classObj = (id<JBFComponentRegisterProtocol>)clazz;
        if ([classObj respondsToSelector:@selector(createComNameKeyAndComConfigObj)]) {
            NSDictionary *dict = [classObj createComNameKeyAndComConfigObj];
            if ([dict count] < 1) {
                NSCAssert(0, @"#%@# 没有按照规范实现函数 createComNameKeyAndComConfigObj，如果你不需要将该类组件化，请在 createComNameKeyAndComConfigObj 函数中返回 #@{JBFComponentPlaceholderName:[JBFComponentConfig doNotNeedComponentAbility]}# ", classname);
            }
            
            for (NSString *keyName in [dict allKeys]) {
                if (![keyName isKindOfClass:[NSString class]] || [keyName length] < 1) {
                    NSCAssert(0, @"%@ 实现 #createComNameKeyAndComConfigObj# 协议，返回字典的 Key 必须是一个描述其 URI 的 String 类型", classname);
                } else {
                    if (![keyName isEqualToString:JBFComponentPlaceholderName]) {
                        JBFComponentConfig *componentConfig = dict[keyName];
                        if (componentConfig == nil || ![componentConfig isMemberOfClass:[JBFComponentConfig class]]) {
                            NSCAssert(0, @"%@ 实现 #createComNameKeyAndComConfigObj# 协议 valueObj 必须为一个 JBFComponentConfig 对象", classname);
                        } else {
                            [componentConfig setValue:classname forKey:@"_className"];
                            
                            if (componentConfig.mvvmAbility == NO) {
                                NSCAssert(0, @" %@ 不具备mvvm能力无法被正常加载", componentConfig.className);
                            }
                            
                            if (NSClassFromString(componentConfig.viewModelClassName) == nil) {
                                NSCAssert(0, @" %@ 找不到 对应的ViewModel类%@ ", componentConfig.className, componentConfig.viewModelClassName);
                            }
                            
                            if (NSClassFromString(componentConfig.viewClassName) == nil) {
                                NSCAssert(0, @" %@ 找不到 对应的View类%@ ", componentConfig.className, componentConfig.viewClassName);
                            }
                            
                            if ([[JBFComponentManager defaultManager].componentConfiguration objectForKey:keyName] != nil) {
                                NSCAssert(0, @"存在了重复的 URI --- #%@# !!!!!!", keyName);
                            } else {
                                jd_checkClassInitFunc(classname);
                                [[JBFComponentManager defaultManager].componentConfiguration setObject:componentConfig forKey:keyName];
                            }
                        }
                    }
                }
            }
        } else {
            NSCAssert(0, @"%@已经注册为一个组件，却未实现 createComNameKeyAndComConfigObj 函数", classname);
        }
    }
}

//第三步，通过传入的 ClassName 检查类的 init 函数和必要参数是否被创建。
static void jd_checkClassInitFunc(NSString *className) {
    Class clazz = NSClassFromString(className);
    if (clazz != nil) {
        Method method = class_getInstanceMethod(clazz, @selector(initWithContext:));
        if (method == nil) {
            NSCAssert(NO, @"类：%@ 必须有一个初始化函数：%@", className, NSStringFromSelector(@selector(initWithContext:)));
        }
    } else {
        NSCAssert(NO, @"找不到类：%@", className);
    }
}

//static void jd_checkClassParamsAndInitFunc(NSString *classname, JBFComponentConfig *connfig) {
//    //参数检查
//    if (classname.length > 0 && NSClassFromString(classname) != nil && [connfig.requiredParameters count] > 0) {
//        NSMutableSet *set = [NSMutableSet set];
//        unsigned int count;
//        objc_property_t *properties = class_copyPropertyList(NSClassFromString(classname), &count);
//        for (int i = 0; i < count; i++) {
//            objc_property_t property = properties[i];
//            NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
//            if ([connfig.requiredParameters containsObject:propertyName]) {
//                const char *attributes = property_getAttributes(property);
//                NSString *attributeStr = [NSString stringWithFormat:@"%s", attributes];
//                NSString *propertyType = nil;
//
//                if ([attributeStr hasPrefix:@"T@"]) {
//                    NSRange endRange = [attributeStr rangeOfString:@"\","];
//                    propertyType = [[attributeStr substringToIndex:endRange.location] stringByReplacingOccurrencesOfString:@"T@\"" withString:@""];
//                } else {
//                    [connfig.propertyMutableMap setObject:@"NSNumber" forKey:propertyName];
//                }
//                if ([propertyType length] > 0) {
//                    [connfig.propertyMutableMap setObject:propertyType forKey:propertyName];
//                }
//            }
//            [set addObject:propertyName];
//        }
//        free(properties);
//        for (NSString *pName in connfig.requiredParameters) {
//            if (![set containsObject:pName]) {
//                NSCAssert(0, @"组件化必要属性:%@ 没有在类: %@ 中声明", pName, classname);
//            }
//        }
//    }
//
//    //初始化函数检查
//    SEL sel = NSSelectorFromString(jd_createInitFuncSelNameByPars(connfig.requiredParameters));
//    Class aClass =  NSClassFromString(classname);
//    if (![aClass instancesRespondToSelector:sel]) {
//        NSCAssert(0, @"#%@#, 没有初始化函数 ---- %@", classname, jd_createInitFuncSelNameByPars(connfig.requiredParameters));
//    }
//}

//根据必选参数和可选参数返回实例的初始化函数名
NSString *jd_createInitFuncSelNameByPars(NSArray *reqPars)
{
    NSMutableString *initFucSelName = [[NSMutableString alloc] initWithString:@"init"];
    if ([reqPars count] < 1) {
        return [NSString stringWithString:initFucSelName];
    } else {
        [initFucSelName appendString:@"With"];
        for (int i =0; i<[reqPars count]; i++) {
            NSString *parName = reqPars[i];
            if (i == 0) {
                parName = jd_upperFirstLetter(parName);
            }
            [initFucSelName appendString:parName];
            [initFucSelName appendString:@":"];
        }
    }
    return [NSString stringWithString:initFucSelName];
}

//首字母大写
NSString * jd_upperFirstLetter(NSString *name)
{
    if (name.length == 0)
    {
        return name;
    }
    NSRange range = [name rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 0)];
    if (range.length == 1)
    {
        NSString *first = [name substringWithRange:range].uppercaseString;
        NSString *otherString = [name substringFromIndex:range.length + range.location];
        return [first stringByAppendingString:otherString];
    }
    return name;
}

BOOL jd_classIsKindOfClass(Class class, Class superClass)
{
    if (class == superClass)
    {
        return YES;
    }
    if (class == nil)
    {
        return NO;
    }
    return jd_classIsKindOfClass(class_getSuperclass(class), superClass);
}

@end
