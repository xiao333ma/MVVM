//
//  HomeViewController.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "HomeViewController.h"
#import "JBFCoreFramework.h"
#import "JBFComponentConfig.h"
#import "HomePipeline.h"
#import "HomeScene.h"

@interface HomeViewController ()

@property(nonatomic, strong)HomePipeline *pipeline;

@end

@implementation HomeViewController

@dynamic pipeline;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    // Do any additional setup after loading the view.
}

- (void)addObservers {
    
    @weakify(self);
    [JBFObserve(self.pipeline, clickIndexPath) handle:^(NSIndexPath *indexPath) {
        @strongify(self);
        NSLog(@"click index ---- %@", indexPath);
        [self startScene:[HomeScene new]];
        NSDictionary *context = @{@"str": self.pipeline.homeModel.dataArray[indexPath.row]};
        [self openURL:@"second" animated:YES context:context];
    }];
}

- (void)changeFromScene:(__kindof HomeScene *)scene {
    NSLog(@"row: %ld", self.pipeline.clickIndexPath.row);
    [self.pipeline.homeModel willChangeValueForKey:@"dataArray"];
    NSLog(@"%@", self.pipeline.homeModel.dataArray);
    [self.pipeline.homeModel.dataArray replaceObjectAtIndex:self.pipeline.clickIndexPath.row withObject:scene.changedText];
    [self.pipeline.homeModel didChangeValueForKey:@"dataArray"];
}

- (NSString *)componentName {
    return JBFComponentPlaceholderName;
}

+ (NSDictionary<NSString *, JBFComponentConfig *> *)createComNameKeyAndComConfigObj {
    return @{JBFComponentPlaceholderName: [JBFComponentConfig quickInitComponentWithViewModelClassName:@"HomeViewModel" viewClassName:@"HomeView"]};
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
