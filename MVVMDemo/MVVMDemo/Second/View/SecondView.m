//
//  SecondView.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "SecondView.h"
#import "SecondPipeline.h"
#import "UIView+JBFPipeline.h"
#import <Masonry.h>
#import "JBFCoreFramework.h"

@interface SecondView () <UITextFieldDelegate>

@property (nonatomic, strong) SecondPipeline *pipeline;
@property (nonatomic, strong) UILabel *label;               //!< 显示上一个页面的文字
@property (nonatomic, strong) UITextField *textField;       //!< 输入新的文字
@property (nonatomic, strong) UIButton *changeButton;       //!< 修改文字按钮

@end

@implementation SecondView

@dynamic pipeline;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewAndLayout];
    }
    return self;
}

- (void)addObservers {
    self.label.text = self.pipeline.originStr;
}

- (void)buttonTapped {
    self.pipeline.inputStr = self.textField.text;
    self.pipeline.buttonTapped = YES;
}

- (void)addSubviewAndLayout {
    
    [self addSubview:self.label];
    [self addSubview:self.textField];
    [self addSubview:self.changeButton];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@100);
        make.centerX.equalTo(self);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(30);
        make.left.equalTo(@10);
        make.right.equalTo(self).offset(-10);
        make.centerX.equalTo(self.label);
    }];
    
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.textField);
        make.top.equalTo(self.textField.mas_bottom).offset(30);
        make.height.equalTo(@50);
    }];
    
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:20];
        _label.textColor = [UIColor redColor];
    }
    return _label;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _textField;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setTitle:@"修改" forState:UIControlStateNormal];
        [_changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _changeButton.backgroundColor = [UIColor redColor];
        [_changeButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

@end
