//
//  TLMovieWriterManager.h
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TLAVFileType
typedef NSString * TLAVFileType NS_EXTENSIBLE_STRING_ENUM;

AVF_EXPORT TLAVFileType const TLAVFileTypeMP4;
AVF_EXPORT TLAVFileType const TLAVFileTypeMOV;

@interface TLMovieWriterManager : NSObject

// 视频播放方向
@property(nonatomic, assign) AVCaptureVideoOrientation referenceOrientation;

@property(nonatomic, assign) AVCaptureVideoOrientation currentOrientation;

@property(nonatomic, strong) AVCaptureDevice *currentDevice;

-(instancetype) init __attribute__((unavailable("init not available, use initWithFileType instead")));
+(instancetype) new __attribute__((unavailable("new not available, use initWithFileType instead")));

- (instancetype)initWithFileType:(TLAVFileType)type;

- (void)start:(void(^)(NSError *error))handle;

- (void)stop:(void(^)(NSURL *url, NSError *error))handle;

- (void)writeData:(AVCaptureConnection *)connection
            video:(AVCaptureConnection *)video
            audio:(AVCaptureConnection *)audio
           buffer:(CMSampleBufferRef)buffer;

@end
