//
//  JBFBaseView.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "JBFBaseView.h"

@implementation JBFBaseView
{
    BOOL __initialized;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self jbf_initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self jbf_initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self jbf_initialize];
}

#pragma mark - impl

- (void)initializeView {
    
}

- (void)updateConstraintsAndLayout {
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

#pragma mark - private

- (void)jbf_initialize {
    if (__initialized == NO) {
        __initialized = YES;
        [self initializeView];
    }
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"[%@ dealloc]", self.class);
}
#endif

@end
