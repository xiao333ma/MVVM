//
//  HomePipeline.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomePipeline.h"

@implementation HomePipeline

- (HomeModel *)homeModel {
    if (!_homeModel) {
        _homeModel = [[HomeModel alloc] init];
    }
    return _homeModel;
}

@end
