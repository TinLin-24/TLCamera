//
//  TLMotionManager.m
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLMotionManager.h"

#import <CoreMotion/CoreMotion.h>

@interface TLMotionManager ()

@property(nonatomic, strong) CMMotionManager *manager;

@end

@implementation TLMotionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[CMMotionManager alloc] init];
        if (!self.manager.deviceMotionAvailable) {
            self.manager = nil;
            return self;
        }
        self.manager.deviceMotionUpdateInterval = 1/15.f;
        __weak __typeof(self)weakSelf = self;
        [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf handleMotionManagerEvent:motion];
            });
        }];
    }
    return self;
}

- (void)handleMotionManagerEvent:(CMDeviceMotion *)deviceMotion {
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            self.deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            self.videoOrientation  = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            self.deviceOrientation = UIDeviceOrientationPortrait;
            self.videoOrientation  = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0) {
            self.deviceOrientation = UIDeviceOrientationLandscapeRight;
            self.videoOrientation  = AVCaptureVideoOrientationLandscapeRight;
        } else {
            self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
            self.videoOrientation  = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}

- (void)dealloc {
    NSLog(@"陀螺仪对象销毁了");
    [self.manager stopDeviceMotionUpdates];
}

@end
