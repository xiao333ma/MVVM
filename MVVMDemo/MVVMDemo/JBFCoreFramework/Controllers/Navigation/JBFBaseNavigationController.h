//
//  JBFBaseNavigationController.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+JBFBaseNavigationController.h"

// RTRootNavigationController v0.6.4 https://github.com/rickytan/RTRootNavigationController

@interface JBFContainerController : UIViewController
@property (nonatomic, readonly, strong) __kindof UIViewController *contentViewController;
@end


/**
 *  @class JBFContainerNavigationController
 *  @brief This Controller will forward all @a Navigation actions to its containing navigation controller, i.e. @b JBFRootNavigationController.
 *  If you are using UITabBarController in your project, it's recommand to wrap it in @b JBFRootNavigationController as follows:
 *  @code
 tabController.viewControllers = @[[[JBFContainerNavigationController alloc] initWithRootViewController:vc1],
                                    [[JBFContainerNavigationController alloc] initWithRootViewController:vc2],
                                    [[JBFContainerNavigationController alloc] initWithRootViewController:vc3],
                                    [[JBFContainerNavigationController alloc] initWithRootViewController:vc4]];
 self.window.rootViewController = [[JBFBaseNavigationController alloc] initWithRootViewControllerNoWrapping:tabController];
 *  @endcode
 */
@interface JBFContainerNavigationController : UINavigationController
@end


/*!
 *  @class JBFBaseNavigationController
 *  @superclass UINavigationController
 *  @coclass JBFContainerController
 *  @coclass JBFContainerNavigationController
 */
@interface JBFBaseNavigationController : UINavigationController

/*!
 *  @brief use system original back bar item or custom back bar item returned by
 *  @c -(UIBarButtonItem*)jbf_customBackItemWithTarget:action: , default is NO
 *  @warning Set this to @b YES will @b INCREASE memory usage!
 */
@property (nonatomic, assign) BOOL useSystemBackBarButtonItem;

/// Weather each individual navigation bar uses the visual style of root navigation bar. Default is @b NO
@property (nonatomic, assign) BOOL transferNavigationBarAttributes;

/*!
 *  @brief use this property instead of @c visibleViewController to get the current visiable content view controller
 */
@property (nonatomic, readonly, strong) UIViewController *jbf_visibleViewController;

/*!
 *  @brief use this property instead of @c topViewController to get the content view controller on the stack top
 */
@property (nonatomic, readonly, strong) UIViewController *jbf_topViewController;

/*!
 *  @brief use this property to get all the content view controllers;
 */
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *jbf_viewControllers;

/**
 *  Init with a root view controller without wrapping into a navigation controller
 *
 *  @param rootViewController The root view controller
 *
 *  @return new instance
 */
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;

/*!
 *  @brief Remove a content view controller from the stack
 *
 *  @param controller the content view controller
 */
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)animated NS_REQUIRES_SUPER;

/*!
 *  @brief Push a view controller and do sth. when animation is done
 *
 *  @param viewController new view controller
 *  @param animated       use animation or not
 *  @param block          animation complete callback block
 */
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void(^)(BOOL finished))block;

/*!
 *  @brief Pop current view controller on top with a complete handler
 *
 *  @param animated       use animation or not
 *  @param block          complete handler
 *
 *  @return The current UIViewControllers(content controller) poped from the stack
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

/*!
 *  @brief Pop to a specific view controller with a complete handler
 *
 *  @param viewController The view controller to pop  to
 *  @param animated       use animation or not
 *  @param block          complete handler
 *
 *  @return A array of UIViewControllers(content controller) poped from the stack
 */
- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                      animated:(BOOL)animated
                                                      complete:(void(^)(BOOL finished))block;

/*!
 *  @brief Pop to root view controller with a complete handler
 *
 *  @param animated use animation or not
 *  @param block    complete handler
 *
 *  @return A array of UIViewControllers(content controller) poped from the stack
 */
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
                                                                  complete:(void(^)(BOOL finished))block;

@end
