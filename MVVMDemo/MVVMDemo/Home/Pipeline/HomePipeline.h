//
//  HomePipeline.h
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "JBFPipeline.h"
#import "HomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomePipeline : JBFPipeline

@property(nonatomic, strong) HomeModel *homeModel;
@property (nonatomic, strong) NSIndexPath *clickIndexPath;             //!< 点击索引

@end

NS_ASSUME_NONNULL_END
