//
//  HomeImageTableViewCell.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomeImageTableViewCell.h"
#import <Masonry.h>

@interface HomeImageTableViewCell ()

@property (nonatomic, strong) UIImageView *pandaImageView;

@end

@implementation HomeImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubViewAndLayout];
    }
    return self;
}

- (void)addSubViewAndLayout {
    [self addSubview:self.pandaImageView];
    [self.pandaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setImgName:(NSString *)imgName {
    self.pandaImageView.image = [UIImage imageNamed:imgName];
}

- (UIImageView *)pandaImageView {
    if (!_pandaImageView) {
        _pandaImageView = [[UIImageView alloc] init];

    }
    return _pandaImageView;
}

@end
