//
//  UIViewController+JBFBaseNavigationController.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <objc/runtime.h>
#import "JBFBaseNavigationController.h"
#import "UIViewController+JBFBaseNavigationController.h"

@implementation UIViewController (JBFBaseNavigationController)
@dynamic jbf_disableInteractivePop;

- (void)setJbf_disableInteractivePop:(BOOL)jbf_disableInteractivePop
{
    objc_setAssociatedObject(self, @selector(jbf_disableInteractivePop), @(jbf_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)jbf_disableInteractivePop
{
    return [objc_getAssociatedObject(self, @selector(jbf_disableInteractivePop)) boolValue];
}

- (Class)jbf_navigationBarClass
{
    return nil;
}

- (JBFBaseNavigationController *)jbf_navigationController
{
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[JBFBaseNavigationController class]]) {
        vc = vc.navigationController;
    }
    return (JBFBaseNavigationController *)vc;
}

@end
