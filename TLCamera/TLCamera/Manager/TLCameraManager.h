//
//  TLCameraManager.h
//  TLCamera
//
//  Created by Mac on 2019/1/7.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLCameraManager : NSObject

- (AVCaptureDeviceInput *)switchCamera:(AVCaptureSession *)session
                                   old:(AVCaptureDeviceInput *)oldinput
                                   new:(AVCaptureDeviceInput *)newinput;

- (id)resetFocusAndExposure:(AVCaptureDevice *)device;

- (id)zoom:(AVCaptureDevice *)device factor:(CGFloat)factor;

- (id)focus:(AVCaptureDevice *)device point:(CGPoint)point;

- (id)expose:(AVCaptureDevice *)device point:(CGPoint)point;

- (id)changeFlash:(AVCaptureDevice *)device mode:(AVCaptureFlashMode)mode;

- (id)changeTorch:(AVCaptureDevice *)device model:(AVCaptureTorchMode)mode;

- (AVCaptureFlashMode)flashMode:(AVCaptureDevice *)device;

- (AVCaptureTorchMode)torchMode:(AVCaptureDevice *)device;

@end
