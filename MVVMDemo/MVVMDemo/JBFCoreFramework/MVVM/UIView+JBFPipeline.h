//
//  UIView+JDPipeline.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JBFPipeline;

@protocol JBFViewPipelineInterface <NSObject>

@required
- (void)addObservers;

@optional
- (void)setupSubViewsPipline:(JBFPipeline *)rootPipeline;

@end

/**
 *  UIView+JDViewPipeline Category
 *
 *  UIView category for pipeline
 */
@interface UIView (JBFViewPipeline) <JBFViewPipelineInterface>

@property (nonatomic, strong)JBFPipeline *pipeline;

@end
