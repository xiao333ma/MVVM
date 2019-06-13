//
//  JBFViewController.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBFViewModel.h"
#import "JBFPipeline.h"
#import "JBFScene.h"
#import "JBFBaseView.h"
#import "JBFComponentManager.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - JBFViewControllerMVVMInterface

@protocol JBFViewControllerMVVMInterface <NSObject>

@required

/**
 *  纵向通信
 *  This method is used to add observer of the pipeline data.
 */
- (void)addObservers;

@optional

/**
 *  横向通信
 */
- (void)changeFromScene:(__kindof JBFScene *)scene;

@end

#pragma mark - JBFBaseViewController

/**
 *  Basic View Controller for all the view controller in our app.
 *
 *  There are three basic elements in a view controller:
 *  1. viewModel, which is used to handle all the business logic
 *  2. container view, which is the container view of all the subviews
 *  3. pipeline, which is used to handle the data flow
 */
@interface JBFBaseViewController : UIViewController <JBFComponentRegisterProtocol, JBFViewControllerMVVMInterface>

@property (nonatomic, strong, readonly) JBFViewModel<JBFViewModel> *viewModel;
@property (nonatomic, strong, readonly) JBFPipeline *pipeline;
@property (nonatomic, strong, readonly) JBFScene *scene;
@property (nonatomic, strong, readonly) JBFBaseView *containerView;
@property (nonatomic,   copy, readonly) NSString *url;

- (instancetype)initWithContext:(nullable NSDictionary *)context;

+ (__kindof JBFBaseViewController *)createControllerByName:(nonnull NSString *)viewControllerName
                                             viewModelName:(nonnull NSString *)viewModelName
                                                  viewName:(nonnull NSString *)viewName
                                                   context:(nullable NSDictionary *)context;

- (instancetype)initWithViewModelName:(nonnull NSString *)viewModelClassName
                             viewName:(nonnull NSString *)viewClassName
                              context:(nullable NSDictionary *)context;

/**
 * 通过调用此函数开启一个场景，用于跨多个 VC 间通信
 */
- (void)startScene:(__kindof JBFScene *)secne;

/**
 * 关掉一个场景
 */
- (void)closeScene;

/**
 * 刷新页面
 */
- (void)refreshView;

@end

#pragma mark - JBFOpenControllerContext

@protocol JBFOpenControllerContext <NSObject>

@required
@property (nonatomic, readonly) UIViewController *sourceController;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, copy) dispatch_block_t block;

@end

#pragma mark - UIViewController JBFOpen Category

typedef NS_ENUM(NSInteger, JBFOpenControllerMode) {
    JBFOpenControllerModePush = 0, //Default
    JBFOpenControllerModePresent,
    JBFOpenControllerModePresentWithNavigation
};

@interface UIViewController(JBFOpen) <JBFComponentRegisterProtocol>

//开启类型
@property (nonatomic, assign) JBFOpenControllerMode openControllerMode;
@property (nonatomic, assign) BOOL removePreVCWhenDidAppear;

//开启
- (void)openURL:(NSString *)url animated:(BOOL)animated context:(nullable NSDictionary *)context;
- (void)openURL:(NSString *)url animated:(BOOL)animated context:(nullable NSDictionary *)context removeSelf:(BOOL)isRemoveSelf;
- (void)openURL:(NSString *)url animated:(BOOL)animated completion:(void (^ __nullable)(void))completion context:(nullable NSDictionary *)context;
- (void)openURL:(NSString *)url animated:(BOOL)animated completion:(void (^ __nullable)(void))completion context:(nullable NSDictionary *)context removeSelf:(BOOL)isRemoveSelf;

- (void)openURL:(NSString *)url animated:(BOOL)animated openControllerMode:(JBFOpenControllerMode)mode completion:(void (^ __nullable)(void))completion context:(nullable NSDictionary *)context removeSelf:(BOOL)isRemoveSelf;

//关闭
- (void)closeSelfAnimated:(BOOL)animated;
- (void)closeSelfAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

/**
 * 具体执行打开的的操作，但是如果子类重写该函数的话一定要调用 super
 * @param context 上下文
 */
- (void)handleOpenControllerByContext:(id<JBFOpenControllerContext>)context NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
