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

- (void)finishRecordVideo:(UIImage *)videoImage videoPathUrl:(NSURL *)pathUrl;

@end

@interface TLCaptureManager : NSObject

@property(nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic, weak) id<TLCaptureManagerDelegate> delegate;

- (void)startRunningSession;

- (void)stopRunningSession;

- (void)takePicture;

- (void)startVideoRecorder;

- (void)stopVideoRecorder;

- (void)switchCamera;

@end
