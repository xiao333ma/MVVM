//
//  JBFComponentConfig.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFComponentConfig : NSObject

@property (nonatomic,readonly,copy) NSString *className;

@end

@interface JBFComponentConfig (MVVM)

@property (nonatomic, copy,  readonly) NSString *viewModelClassName;
@property (nonatomic, copy,  readonly) NSString *viewClassName;
@property (nonatomic, assign,readonly) BOOL mvvmAbility;

+ (instancetype)quickInitComponentWithViewModelClassName:(NSString *)viewModelClassName
                                           viewClassName:(NSString *)viewClassName;

+ (instancetype)doNotNeedMVVMAbilityComponent;

@end

