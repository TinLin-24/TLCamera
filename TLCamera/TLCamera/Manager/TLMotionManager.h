//
//  TLMotionManager.h
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLMotionManager : NSObject

@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

@end
