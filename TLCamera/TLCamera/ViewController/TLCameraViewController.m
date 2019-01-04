//
//  TLCameraViewController.m
//  TLCamera
//
//  Created by Mac on 2019/1/3.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLCameraViewController.h"

@interface TLCameraViewController ()

@property(nonatomic, strong) TLCaptureManager *captureManager;

@end

@implementation TLCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.captureManager.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureManager.previewLayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.captureManager startRunningSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.captureManager stopRunningSession];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (TLCaptureManager *)captureManager {
    if (!_captureManager) {
        _captureManager = [[TLCaptureManager alloc] init];
    }
    return _captureManager;
}

@end
