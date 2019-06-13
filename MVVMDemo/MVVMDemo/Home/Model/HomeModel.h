//
//  HomeModel.h
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeModel : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *dataArray;             //!< 数据源

@end

NS_ASSUME_NONNULL_END
