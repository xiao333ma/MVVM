//
//  SecondViewController.m
//  MVVMDemo
//
//  Created by xiaoma on 4/23/19.
//  Copyright © 2019 xiaoma. All rights reserved.
//

#import "SecondViewController.h"
#import "SecondPipeline.h"
#import "JBFCoreFramework.h"
#import "JBFComponentConfig.h"
#import "HomeScene.h"

@interface SecondViewController ()

@property (nonatomic, strong) SecondPipeline *pipeline;

@end

@implementation SecondViewController

@dynamic pipeline;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)addObservers {
    @weakify(self);
    [JBFObserve(self.pipeline, buttonTapped) handle:^(id newValue) {
        @strongify(self);
        HomeScene *homeScene = (HomeScene *)self.scene;
        homeScene.changedText = self.pipeline.inputStr;
        [self.jbf_navigationController popViewControllerAnimated:YES];
    }];
    
}

- (NSString *)componentName {
    return @"second";
}

+ (NSDictionary<NSString *, JBFComponentConfig *> *)createComNameKeyAndComConfigObj {
    return @{@"second": [JBFComponentConfig quickInitComponentWithViewModelClassName:@"SecondViewModel" viewClassName:@"SecondView"]};
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
