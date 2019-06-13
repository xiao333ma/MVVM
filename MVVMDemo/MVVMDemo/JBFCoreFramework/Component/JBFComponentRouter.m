//
//  JBFComponentRouter.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFComponentRouter.h"
#import "JBFComponentConfig.h"
#import "JBFBaseViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString * const JBFComponentRootURL = @"https://m.jr.jd.com/";

#define Min_URL_Length  9
#define HTTP @"http://"
#define HTTPS @"https://"

@interface JBFComponentManager(Private)
@property (nonatomic,strong) NSMutableDictionary <NSString *,JBFComponentConfig*> *componentConfiguration;
NSString *jd_createInitFuncSelNameByPars(NSArray *reqPars);
@end

@implementation JBFComponentRouter

#pragma mark - signInstans
+ (instancetype)defaultRouter {
    static JBFComponentRouter *s_router = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_router = [[JBFComponentRouter alloc] init];
    });
    return s_router;
}

#pragma mark -init
- (instancetype)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

#pragma mark - impl
- (BOOL)isHttpURL:(NSString *)url {
    if ((![url hasPrefix:HTTP] && ![url hasPrefix:HTTPS]) || [url length] < Min_URL_Length) {
        return NO;
    }else{
        return YES;
    }
}
- (BOOL)isExistNative:(NSString*)url {
    NSString *uri_str = [url copy];
    if ([url hasPrefix:@"na://"] ) {
       url = [uri_str stringByReplacingOccurrencesOfString:@"na://" withString:@""];
    }
    
    if ([[JBFComponentManager defaultManager].componentConfiguration objectForKey:url]) {
        return YES;
    }
    return NO;
}

- (id<JBFComponentRegisterProtocol>)routerComponentFromURL:(NSString *)url context:(NSDictionary *)context{
  @synchronized (self) {
    if (url.length<1) {
        return nil;
    }else{
        JBFComponentConfig *config;
        
        if ([url hasPrefix:@"na://"] ) {
            NSString *uri_str = [url copy];
            url = [uri_str stringByReplacingOccurrencesOfString:@"na://" withString:@""];
        }
        
        if ([[JBFComponentManager defaultManager].componentConfiguration objectForKey:url] != nil) {
            config = [[JBFComponentManager defaultManager].componentConfiguration objectForKey:url];
        }else{
            NSString *uri = [self jd_getcomponentNameFromURL:url];
            if (uri.length <1) {
                return nil;
            }
            config = [[JBFComponentManager defaultManager].componentConfiguration objectForKey:uri];
        }
        if (config != nil) {
            Class clazz = NSClassFromString(config.className);
            id instance = [clazz alloc];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            SEL sl = @selector(initWithContext:);
#pragma clang diagnostic pop
            if ([instance respondsToSelector:sl]) {
                NSDictionary *mapContext = context;
                if ([mapContext count] == 0) {
                     mapContext = [self jd_getParameterDictByURL:url];
                }
                
                NSObject *instanceObj = instance;
                if ([instanceObj isKindOfClass:[JBFBaseViewController class]]) {
                    [instanceObj setValue:url forKey:@"_url"];
                }
                
                
                id obj =  ((NSObject *(*)(id,SEL,id))objc_msgSend)(instanceObj,sl,mapContext);
                return obj;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
      }
   }

return nil;
}

#pragma mark - runtime
+ (void)load {
    [JBFComponentRouter defaultRouter];
}

#pragma  mark -private

- (NSString *)jd_getcomponentNameFromURL:(NSString *)url{
    NSRange range = [url rangeOfString:@"?"];
    NSString *tempStr = [url stringByReplacingOccurrencesOfString:JBFComponentRootURL withString:@""];
    NSString *newStr = nil;
    if (range.location != NSNotFound) {
        newStr = [tempStr substringToIndex:[tempStr rangeOfString:@"?"].location];
    }
    return newStr;
}

- (NSDictionary <NSString *,NSString *>*)jd_getParameterDictByURL:(NSString *)url {
    NSRange range = [url rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        NSString *str = [url substringFromIndex:range.location+range.length];
        if (str.length<1) {
            return nil;
        }else{
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            NSArray *parArray = [str componentsSeparatedByString:@"&"];
            for (NSString *par in parArray) {
                if (par.length>0) {
                    NSArray *aParArray = [par componentsSeparatedByString:@"="];
                    if(aParArray.count == 2){
                        if([aParArray[0] length]>0 && [aParArray[1] length]>0){
                            [parameters setObject:aParArray[1] forKey:aParArray[0]];
                        }
                    }
                }
            }
            if ([parameters count]>0) {
                return [NSDictionary dictionaryWithDictionary:parameters];
            }else{
                return nil;
            }
        }
    }else{
        return nil;
    }
}

@end
