//
//  TLCameraViewController.m
//  TLCamera
//
//  Created by Mac on 2019/1/3.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLCameraViewController.h"

@interface TLCameraViewController ()<TLCameraControlViewDelegate>

@property(nonatomic, strong) TLCaptureManager *captureManager;

@property(nonatomic, strong) TLCameraControlView *controlView;

@end

@implementation TLCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.captureManager.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureManager.previewLayer];
    
    [self.view addSubview:self.controlView];
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

#pragma mark - TLCameraControlViewDelegate

- (void)takePhotoAction:(TLCameraControlView *)controlView {
    [self.captureManager takePicture];
}

- (void)startRecordVideoAction:(TLCameraControlView *)controlView {
    [self.captureManager startVideoRecorder];
}

- (void)stopRecordVideoAction:(TLCameraControlView *)controlView {
    [self.captureManager stopVideoRecorder];
}

- (void)switchCameraAction:(TLCameraControlView *)controlView handle:(void (^)(NSError *))handle {
    [self.captureManager switchCamera];
}

#pragma mark - Getter

- (TLCaptureManager *)captureManager {
    if (!_captureManager) {
        _captureManager = [[TLCaptureManager alloc] init];
    }
    return _captureManager;
}

- (TLCameraControlView *)controlView {
    if (!_controlView) {
        _controlView = [[TLCameraControlView alloc] initWithFrame:self.view.bounds];
        _controlView.delegate = self;
    }
    return _controlView;
}

@end
