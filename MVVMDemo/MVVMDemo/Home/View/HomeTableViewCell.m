//
//  HomeTableViewCell.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomeTableViewCell.h"
#import <Masonry.h>

@interface HomeTableViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubViewAndLayout];
    }
    return self;
}

- (void)addSubViewAndLayout {
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:20];
        _label.textColor = [UIColor redColor];
    }
    return _label;
}

@end
