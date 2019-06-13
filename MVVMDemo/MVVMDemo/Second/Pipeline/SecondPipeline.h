//
//  SecondPipeline.h
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "JBFPipeline.h"

NS_ASSUME_NONNULL_BEGIN

@interface SecondPipeline : JBFPipeline

@property (nonatomic, copy) NSString *originStr;            //!< 上一个页面传过来的 str
@property (nonatomic, copy) NSString *inputStr;             //!< 新生成的 str
@property (nonatomic, assign) BOOL buttonTapped;            //!< 按钮点击

@end

NS_ASSUME_NONNULL_END
