//
//  TLCaptureManager.h
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TLCaptureManagerDelegate <NSObject>
@optional;

- (void)finishTakePicture:(UIImage *)photo;

- (void)finishRecordVideo:(UIImage *)videoImage VideoPathUrl:(NSURL *)pathUrl;

@end

@interface TLCaptureManager : NSObject

@property(nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic, weak) id<TLCaptureManagerDelegate> delegate;

//-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
//+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void)startRunningSession;

- (void)stopRunningSession;

- (void)takePicture;

- (void)startVideoRecorder;

- (void)stopVideoRecorder;

- (void)swicthCameraAction;

@end
