//
//  UIViewController+JBFBaseNavigationController.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JBFBaseNavigationController;

@protocol JBFNavigationItemCustomizable <NSObject>

@optional

/*!
 *  @brief Override this method to provide a custom back bar item, default is a normal @c UIBarButtonItem with title @b "Back"
 *
 *  @param target the action target
 *  @param action the pop back action
 *
 *  @return a custom UIBarButtonItem
 */
- (UIBarButtonItem *)customBackItemWithTarget:(id)target action:(SEL)action DEPRECATED_MSG_ATTRIBUTE("use jbf_customBackItemWithTarget:action: instead!");
- (UIBarButtonItem *)jbf_customBackItemWithTarget:(id)target action:(SEL)action;

@end

@interface UIViewController (JBFBaseNavigationController) <JBFNavigationItemCustomizable>

/*!
 *  @brief set this property to @b YES to disable interactive pop
 */
@property (nonatomic, assign) BOOL jbf_disableInteractivePop;

/*!
 *  @brief @c self\.navigationControlle will get a wrapping @c UINavigationController, use this property to get the real navigation controller
 */
@property (nonatomic, readonly, strong) JBFBaseNavigationController *jbf_navigationController;

/*!
 *  @brief Override this method to provide a custom subclass of @c UINavigationBar, defaults return nil
 *
 *  @return new UINavigationBar class
 */
- (Class)jbf_navigationBarClass;

@end
