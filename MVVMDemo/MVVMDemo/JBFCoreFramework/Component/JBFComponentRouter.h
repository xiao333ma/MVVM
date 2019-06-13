//
//  JBFComponentRouter.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFComponentManager.h"

extern NSString * const JBFComponentRootURL;

/* JBF组件化路由跳转规范(符合 m站 H5 规范)
 http://m.jr.jd.com/spe/qyy/main/index.html?userType=51&qingfrom=url
 1、路由根地址为：http://m.jr.jd.com
 2、资源 URI命名：/spe/qyy/main/index
 3、后缀 .html 跟 m站吻合，也针对搜索引擎友好
 4、参数放在最后以 '?' 开头，并用 '=' 链接 key-value，多个参数用 '&' 分割
 */

__attribute__((objc_subclassing_restricted))
@interface JBFComponentRouter : NSObject

/**
 sign method
 
 @return JBFComponentRouter instance
 */
+ (instancetype)defaultRouter;

- (id<JBFComponentRegisterProtocol>)routerComponentFromURL:(NSString *)url context:(NSDictionary *)context;

- (BOOL)isHttpURL:(NSString *)url;

- (BOOL)isExistNative:(NSString*)url;
@end
