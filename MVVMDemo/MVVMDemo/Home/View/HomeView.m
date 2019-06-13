//
//  HomeView.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomeView.h"
#import "HomePipeline.h"
#import "UIView+JBFPipeline.h"
#import <Masonry.h>
#import "HomeTableViewCell.h"
#import "JBFCoreFramework.h"
#import "HomeImageTableViewCell.h"

#define TableViewTextCellID @"textCell"
#define TableViewImageCellID @"imageCell"

@interface HomeView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) HomePipeline *pipeline;
@property (nonatomic, strong) UITableView *tableView;             //!< tableView

@end

@implementation HomeView

@dynamic pipeline;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewsAndLayout];
    }
    return self;
}

- (void)addObservers {
    
    @weakify(self);
    [JBFObserve(self.pipeline.homeModel, dataArray) handle:^(id newValue) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
}

#pragma mark - Layout Method

- (void)addSubviewsAndLayout {
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pipeline.homeModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pipeline.homeModel.dataArray[indexPath.row] hasSuffix:@"jpg"] ? 128 : 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pipeline.homeModel.dataArray[indexPath.row] hasSuffix:@"jpg"]) {
        HomeImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewImageCellID forIndexPath:indexPath];
        cell.imgName = self.pipeline.homeModel.dataArray[indexPath.row];
        return cell;
    } else {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewTextCellID forIndexPath:indexPath];
        cell.text = self.pipeline.homeModel.dataArray[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.pipeline.clickIndexPath = indexPath;
}

#pragma mark - Target Method

#pragma mark - Assist Method

#pragma mark - Accessor Method


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:TableViewTextCellID];
        [_tableView registerClass:[HomeImageTableViewCell class] forCellReuseIdentifier:TableViewImageCellID];
    }
    return _tableView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
