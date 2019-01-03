//
//  BaseViewController.m
//  Demo
//
//  Created by TinLin on 2018/8/2.
//  Copyright © 2018年 TinLin. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configure];
}

- (void)configure {
    
}

- (void)dealloc{
    TLDealloc;
}

@end
