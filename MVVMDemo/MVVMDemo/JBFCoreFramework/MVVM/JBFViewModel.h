//
//  JBFViewModel.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JBFPipeline;

//typedef void (^JBFSceneWillPopedBlock)(NSDictionary *context);

#pragma mark - JDStore

/**
 *  JDStore Protocol
 *
 *  This protocol defines methods for a store that it could provide
 *  what features.
 */
@protocol JBFViewModel <NSObject>

/**
 *  Pipeline for the scene
 */
- (__kindof JBFPipeline *)pipeline;

/**
 *  Fetch data
 *
 *  We create store instance at the init method of view controller,
 *  but we should fetch data in the viewDidLoad or viewWillAppeared method,
 *  so we provide this method.
 */
- (void)fetchData;


/**
 *  add observer for the pipeline data.
 */
- (void)addObservers;


/**
 *  call the method before addObservers do somethings by prepare;
 */
- (void)prepare;

@optional

/**
 *  cancel all the data requests.
 */
- (void)cancel;

@end

#pragma mark - JDStore class

/**
 *  Basic class for store
 *
 *  A store is used to handle all the business logic
 */
@interface JBFViewModel : NSObject <JBFViewModel>

/**
 *  context for this store
 */
@property (nonatomic, strong) NSDictionary *context;

/**
 *  initialize method
 *
 *  @param context context for current scene
 *
 *  @return JBFViewModel instance
 */
- (instancetype)initWithContext:(NSDictionary *)context;

@end
