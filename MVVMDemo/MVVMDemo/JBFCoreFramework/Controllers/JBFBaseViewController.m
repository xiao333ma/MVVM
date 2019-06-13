//
//  JBFViewController.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFBaseViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JBFComponentRouter.h"
#import "JBFComponentConfig.h"
#import "UIView+JBFPipeline.h"
#import "JBFBaseNavigationController.h"


@interface JBFBaseViewController ()

@property (nonatomic, strong) JBFScene *scene;
@property (nonatomic,   copy) NSString *viewClassName;
@property (nonatomic, strong) JBFBaseView *containerView;
@property (nonatomic, strong) JBFViewModel *viewModel;
@property (nonatomic, strong) JBFScene *originalScene;

@end

@implementation JBFBaseViewController

@synthesize containerView = _containerView;
@synthesize pipeline = _pipeline;
@synthesize scene = _scene;
@synthesize viewModel = _viewModel;
@synthesize originalScene = _originalScene;
@synthesize url = _url;

#pragma mark - init

+ (JBFBaseViewController *)createControllerByName:(NSString *)viewControllerName
                                    viewModelName:(NSString *)viewModelName
                                         viewName:(NSString *)viewName
                                          context:(NSDictionary *)context {
    
    Class vcClass = NSClassFromString(viewControllerName);
    NSAssert(vcClass != nil, @"没有找到对应 viewController: %@", viewControllerName);
    return [[vcClass alloc] initWithViewModelName:viewModelName viewName:viewName context:context];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", self.class);
}
#endif

- (instancetype)initWithViewModelName:(NSString *)viewModelClassName
                             viewName:(NSString *)viewClassName
                              context:(NSDictionary *)context {
#ifdef DEBUG
    Class viewModelClass = NSClassFromString(viewModelClassName);
    NSAssert(viewModelClass != nil, @"%@没有找到对应 viewModel: %@", self, viewModelClassName);
    
    Class viewClass = NSClassFromString(viewClassName);
    NSAssert(viewClass != nil, @"%@没有找到对应 view:%@", self, viewClassName);
#endif
    self = [super init];
    
    if (self != nil) {
        self.viewModel = [self jd_createViewModelByClassName:viewModelClassName context:context];
        _viewClassName = viewClassName;
    }
    
    return self;
}

- (instancetype)initWithContext:(NSDictionary *)context {
    self = [super init];
    if (self != nil) {
        JBFComponentConfig *connfig = [self jd_getComponentConfigByURI:[self componentName]];
        if (connfig.mvvmAbility) {
            self.viewModel = [self jd_createViewModelByClassName:connfig.viewModelClassName context:context];
        }
    }
    return self;
}

#pragma mark - life style

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self jd_MVVM_ability];
    if (self.containerView != nil) {
        self.view = self.containerView;
    }
    [self addObservers];
    
    // 判断是否移除前一页面
    if (self.removePreVCWhenDidAppear) {
        self.removePreVCWhenDidAppear = NO;
        JBFBaseNavigationController *navi = self.jbf_navigationController;
        if (navi && [navi isKindOfClass:[JBFBaseNavigationController class]]) {
            NSUInteger count = navi.jbf_viewControllers.count;
            if (count >= 2) {
                JBFBaseViewController *preVC = navi.jbf_viewControllers[count - 2];
                [navi removeViewController:preVC];
            }
        }
    }
}

#pragma mark - sence

- (void)startScene:(JBFScene *)scene {
    if (![scene isKindOfClass:[JBFScene class]]) {
        NSAssert(NO, @"%@ 不是 JBFScene 的子类", scene);
    }
    if (self.scene == nil) {
        self.scene = scene;
    } else {
        self.originalScene = self.scene;
        self.scene = scene;
    }
}

- (void)closeScene {
    self.scene = nil;
    if (self.originalScene != nil) {
        self.scene = self.originalScene;
        self.originalScene = nil;
    }
}

- (void)refreshView {
    
}

#pragma mark - JBFViewControllerPipelineInterface

- (void)addObservers {
    NSAssert(NO, @"该协议只能在子类中实现，父类中不能实现");
}

#pragma mark - pravate

// 通过组件化构造 Context
- (NSDictionary *)jd_autoCreateContext {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        const char *attributes = property_getAttributes(property);
        NSString *attributeStr = [NSString stringWithFormat:@"%s", attributes];
        NSArray *arrayStr = [attributeStr componentsSeparatedByString:@","];
        NSString *tempStr = [arrayStr lastObject];
        if ([tempStr rangeOfString:@"V"].location != NSNotFound) {
            NSString *iVarStr = [tempStr stringByReplacingOccurrencesOfString:@"V" withString:@""];
            Ivar i_var = class_getClassVariable([self class], [iVarStr UTF8String]);
            if (iVarStr.length > 0 && i_var != NULL) {
                id value =  [self valueForKeyPath:iVarStr];
                if (value != nil) {
                    [map setObject:value forKey:propertyName];
                }
            }
        }
    }
    free(properties);
    if ([map count] > 0) {
        return [NSDictionary dictionaryWithDictionary:map];
    } else {
        return nil;
    }
}

- (void)jd_MVVM_ability {
    if (self.viewClassName.length > 0) {
        self.containerView = [self jd_createContainerViewByClassName:self.viewClassName];
    } else {
        JBFComponentConfig *connfig = [self jd_getComponentConfigByURI:[self componentName]];
        if (connfig == nil || connfig.mvvmAbility == NO) return;
        if (self.viewModel == nil ) {
            self.viewModel = [self jd_createViewModelByClassName:connfig.viewModelClassName context:[self jd_autoCreateContext]];
        }
        self.containerView = [self jd_createContainerViewByClassName: connfig.viewClassName];
    }
}

- (JBFViewModel *)jd_createViewModelByClassName:(NSString *)viewModelClassName context:(NSDictionary *)context {
    JBFViewModel *viewModel = nil;
    if (viewModelClassName.length > 0 &&  NSClassFromString(viewModelClassName) != nil ) {
        __unsafe_unretained Class clazz = NSClassFromString(viewModelClassName);
        if ([clazz conformsToProtocol:@protocol(JBFViewModel)] && [clazz isSubclassOfClass:[JBFViewModel class]]) {
            viewModel = [[clazz alloc] initWithContext:context];
        }
    }
    return viewModel;
}

- (__kindof JBFBaseView *)jd_createContainerViewByClassName:(NSString *)viewClassName {
    JBFBaseView *aView = nil;
    if (viewClassName.length > 0 && NSClassFromString(viewClassName) != nil ) {
        __unsafe_unretained Class clazz = NSClassFromString(viewClassName);
        if ([clazz isSubclassOfClass:[UIView class]]) {
            aView = [[clazz alloc] initWithFrame:self.view.bounds];
            if (![aView isKindOfClass:[JBFBaseView class]]) {
                NSAssert(NO, @"%@ 不是 JBFBaseView 的子类", viewClassName);
            }
        }
    }
    return aView;
}

- (JBFComponentConfig *)jd_getComponentConfigByURI:(NSString *)uri {
    if (uri.length < 1) {
        return nil;
    }
    NSDictionary *dict = [[self class] createComNameKeyAndComConfigObj];
    return dict[uri];
}

#pragma mark - override getter

- (void)setViewModel:(JBFViewModel<JBFViewModel> *)viewModel {
    _viewModel = viewModel;
    if (self.viewModel != nil && [self.viewModel respondsToSelector:@selector(pipeline)]) {
        _pipeline = [self.viewModel pipeline];
    }
}

- (void)setContainerView:(JBFBaseView *)containerView {
    _containerView = containerView;
    if (_containerView != nil) {
        self.containerView.pipeline = self.viewModel.pipeline;
    }
}

- (void)setScene:(JBFScene *)scene {
    _scene = scene;
    if (_scene != nil && [_scene isKindOfClass:[JBFScene class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ((void(*)(id, SEL, id))objc_msgSend)(_scene, @selector(jd_addController:), self);
#pragma clang diagnostic pop
    }
}

- (void)setOriginalScene:(JBFScene *)originalScene {
    _originalScene = originalScene;
}

#pragma mark - runtime

+ (void)load {
    [[JBFComponentManager defaultManager] registerComponentWithClazz:self];
}

#pragma mark - JBFComponentRegisterProtocol

- (NSString *)componentName {
    return  JBFComponentPlaceholderName;
}

+ (NSDictionary<NSString*,JBFComponentConfig *> *)createComNameKeyAndComConfigObj {
    return @{JBFComponentPlaceholderName:[JBFComponentConfig doNotNeedMVVMAbilityComponent]};
}

- (Class)whichJBFWebViewControllerClassOpenH5 {
    return NSClassFromString(@"JBFBaseWebViewController");
}

@end

#pragma mark - JBFOpenControllerContextObject

@interface JBFOpenControllerContextObject : NSObject <JBFOpenControllerContext>
@property (nonatomic, strong) UIViewController *sourceController;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, copy) dispatch_block_t block;
@end

@implementation JBFOpenControllerContextObject
@end

#pragma mark - UIViewController JBFOpen Category

const char * JBFBaseViewController_p_JBFOpenControllerMode = "JBFBaseViewController_p_JBFOpenControllerMode";
const char * JBFBaseViewController_p_JBFRemovePreVCWhenDidAppear = "JBFBaseViewController_p_JBFRemovePreVCWhenDidAppear";

@implementation  UIViewController(JBFOpen)

#pragma mark - openControllerMode

- (void)setOpenControllerMode:(JBFOpenControllerMode)openControllerMode {
    objc_setAssociatedObject(self, &JBFBaseViewController_p_JBFOpenControllerMode, [NSNumber numberWithInteger:openControllerMode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JBFOpenControllerMode)openControllerMode {
    NSNumber *num = objc_getAssociatedObject(self, &JBFBaseViewController_p_JBFOpenControllerMode);
    if (num == nil) {
        return JBFOpenControllerModePush;
    } else {
        return [num integerValue];
    }
}

- (void)setRemovePreVCWhenDidAppear:(BOOL)removePreVCWhenDidAppear {
    objc_setAssociatedObject(self, &JBFBaseViewController_p_JBFRemovePreVCWhenDidAppear, @(removePreVCWhenDidAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)removePreVCWhenDidAppear {
    NSNumber *num = objc_getAssociatedObject(self, &JBFBaseViewController_p_JBFRemovePreVCWhenDidAppear);
    if (num == nil) {
        return NO;
    } else {
        return [num boolValue];
    }
}

#pragma mark - openController

- (void)openController:(__kindof UIViewController *)targetViewController
              animated:(BOOL)animated
    openControllerMode:(JBFOpenControllerMode)mode
            completion:(void (^)(void))completion
            removeSelf:(BOOL)isRemoveSelf {
    
    if (![targetViewController isKindOfClass:[UIViewController class]]) return;
    
    UIViewController *sourceViewController = self;
    if ([targetViewController respondsToSelector:@selector(handleOpenControllerByContext:)]) {
        targetViewController.openControllerMode = mode;
        targetViewController.removePreVCWhenDidAppear = isRemoveSelf;
        
        JBFOpenControllerContextObject *context = [[JBFOpenControllerContextObject alloc] init];
        context.sourceController = sourceViewController;
        context.animated = animated;
        context.block = completion;
        ((void(*)(id, SEL, id))objc_msgSend)(targetViewController, @selector(handleOpenControllerByContext:), context);
    }
}

#pragma mark - openURL

- (void)openURL:(NSString *)url animated:(BOOL)animated context:(NSDictionary *)context {
    [self openURL:url animated:animated openControllerMode:JBFOpenControllerModePush completion:nil context:context removeSelf:NO];
}

- (void)openURL:(NSString *)url animated:(BOOL)animated context:(nullable NSDictionary *)context removeSelf:(BOOL)isRemoveSelf {
    [self openURL:url animated:animated openControllerMode:JBFOpenControllerModePush completion:nil context:context removeSelf:isRemoveSelf];
}

- (void)openURL:(NSString *)url animated:(BOOL)animated completion:(void (^)(void))completion context:(NSDictionary *)context {
    [self openURL:url animated:animated openControllerMode:JBFOpenControllerModePush completion:completion context:context removeSelf:NO];
}

- (void)openURL:(NSString *)url animated:(BOOL)animated completion:(void (^ __nullable)(void))completion context:(nullable NSDictionary *)context removeSelf:(BOOL)isRemoveSelf {
    [self openURL:url animated:animated openControllerMode:JBFOpenControllerModePush completion:completion context:context removeSelf:isRemoveSelf];
}

- (void)openURL:(NSString *)url animated:(BOOL)animated openControllerMode:(JBFOpenControllerMode)mode completion:(void (^)(void))completion context:(NSDictionary *)context removeSelf:(BOOL)isRemoveSelf {
    JBFComponentRouter *router = [JBFComponentRouter defaultRouter];
    id obj = [router routerComponentFromURL:url context:context];
    if (obj != nil && [obj isKindOfClass:[JBFBaseViewController class]]) {
        UIViewController *controllerObj = obj;
        [self openController:controllerObj animated:animated openControllerMode:mode completion:completion removeSelf:isRemoveSelf];
    } else {
        // UIWebView or WKWebView
        Class webViewControllerClass = [self whichJBFWebViewControllerClassOpenH5];
        if ([router isHttpURL:url] && webViewControllerClass != nil) {
//            JBFBaseViewController *webVC = [[webViewControllerClass alloc] initWithURL:url context:context];
//            [self openController:webVC animated:animated openControllerMode:mode completion:completion removeSelf:isRemoveSelf];
        }
    }
}

- (void)closeSelfAnimated:(BOOL)animated {
    [self closeSelfAnimated:animated completion:nil];
}

- (void)closeSelfAnimated:(BOOL)animated completion:(void (^)(void))completion {
    switch (self.openControllerMode) {
        case JBFOpenControllerModePush:{
            JBFBaseNavigationController *navi = self.jbf_navigationController;
            // 如果当前页面是 navi 仅剩的一个 VC，则不能关闭
            if (![[navi.jbf_viewControllers firstObject] isEqual:self]) {
                if ([[navi.jbf_viewControllers lastObject] isEqual:self]) {
                    // 如果当前页面是栈顶 VC，则调用 popViewControllerAnimated 关闭，支持动画
                    [self.navigationController popViewControllerAnimated:animated];
                } else {
                    // 如果当前页面是栈中间的某一 VC，不在栈顶，则直接移除，无感
                    [self.jbf_navigationController removeViewController:self];
                }
                dispatch_block_t block = completion;
                if (block != nil) {
                    [self performSelector:@selector(jd_inNextRunloopExcuteBlock:) withObject:block afterDelay:0.01f];
                }
            }
        }
            break;
        default:{
            [self dismissViewControllerAnimated:animated completion:completion];
        }
            break;
    }
}

- (void)handleOpenControllerByContext:(id<JBFOpenControllerContext>)context {
    if (context == nil || [context sourceController] == nil) return;
    
    self.hidesBottomBarWhenPushed = YES;
    
    UIViewController *aViewController = [context sourceController];
    
    // 这一段的逻辑有点逆天，就是说可以打开一个 UINavigationController 或者 UITabBarController 但是不能嵌套
    if ([aViewController isKindOfClass:[UITabBarController class]]) {
        aViewController = [(UITabBarController *)aViewController selectedViewController];
    }
    
    if ([aViewController isKindOfClass:[UINavigationController class]]) {
        aViewController = [(UINavigationController *)aViewController viewControllers].lastObject;
    }
    
    if ([aViewController isKindOfClass:[UITabBarController class]] || [aViewController isKindOfClass:[UINavigationController class]]) {
        NSAssert(NO, @"不能打开一个 UINavigationController 或者  UITabBarController 的子类");
        return;
    }
    // end
    
    if ([self isKindOfClass:[JBFBaseViewController class]] && [aViewController isKindOfClass:[JBFBaseViewController class]]) {
        JBFBaseViewController *JBFSelf = (JBFBaseViewController *)self;
        JBFBaseViewController *sourceVC = (JBFBaseViewController *)aViewController;
        JBFSelf.scene = sourceVC.scene;
    }
    
    BOOL animated = [context animated];
    switch (self.openControllerMode) {
            
        case JBFOpenControllerModePresent:{
            [aViewController presentViewController:self animated:animated completion:[context block]];
        }
            break;
            
        case JBFOpenControllerModePresentWithNavigation:{
            UINavigationController *navigation = nil;
            if ([self isKindOfClass:[JBFBaseViewController class]]) {
                JBFBaseViewController *JBFVC = (JBFBaseViewController *)self;
                Class naviClass = NSClassFromString(@"JBFNavigationController");
                if (naviClass != nil) {
                    navigation = [[naviClass alloc] initWithRootViewController:JBFVC];
                }
            } else {
                navigation = [[UINavigationController alloc] initWithRootViewController:self];
            }
            [aViewController presentViewController:navigation animated:animated completion:[context block]];
        }
            break;
            
        default:{
            [aViewController.navigationController pushViewController:self animated:animated];
            dispatch_block_t block = [context block];
            if (block != nil) {
                [self performSelector:@selector(jd_inNextRunloopExcuteBlock:) withObject:block afterDelay:0.01f];
            }
        }
            break;
    }
}

- (void)jd_inNextRunloopExcuteBlock:(dispatch_block_t)block {
    if (block != nil) {
        block();
    }
}

#pragma mark - JBFComponentRegisterProtocol

- (NSString *)componentName {
    return JBFComponentPlaceholderName;
}

+ (NSDictionary<NSString *, JBFComponentConfig *> *)createComNameKeyAndComConfigObj {
    return @{JBFComponentPlaceholderName: [JBFComponentConfig doNotNeedMVVMAbilityComponent]};
}

@end
