//
//  TLMovieWriterManager.m
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLMovieWriterManager.h"

TLAVFileType const TLAVFileTypeMP4 = @"mp4";
TLAVFileType const TLAVFileTypeMOV = @"mov";

@interface TLMovieWriterManager ()

@property(nonatomic, strong) AVAssetWriter *assetWriter;

@property(nonatomic, strong) AVAssetWriterInput *videoInput;

@property(nonatomic, strong) AVAssetWriterInput *audioInput;

@property(nonatomic, strong) dispatch_queue_t videoWriteQueue;

@property(nonatomic, strong) NSURL *movieURL;

@property(nonatomic, assign) TLAVFileType type;

@property(nonatomic, assign) BOOL readyToRecordVideo;

@property(nonatomic, assign) BOOL readyToRecordAudio;

@end

@implementation TLMovieWriterManager

- (instancetype)initWithFileType:(TLAVFileType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        self.videoWriteQueue = dispatch_queue_create("com.tinlin.VideoWriteQueue", DISPATCH_QUEUE_SERIAL);
        self.referenceOrientation = AVCaptureVideoOrientationPortrait;
    }
    return self;
}

#pragma mark - Public

- (void)start:(void(^)(NSError *error))handle {
    self.movieURL = [self makeMovieURL];
    dispatch_async(self.videoWriteQueue, ^{
        NSError *error;
        if (!self.assetWriter) {
            AVFileType type = AVFileTypeMPEG4;
            if (self.type == TLAVFileTypeMOV) {
                type = AVFileTypeQuickTimeMovie;
            }
            self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.movieURL fileType:type error:&error];
        }
        handle(error);
    });
}

- (void)stop:(void(^)(NSURL *url, NSError *error))handle {
    self.readyToRecordAudio = NO;
    self.readyToRecordVideo = NO;
    dispatch_async(self.videoWriteQueue, ^{
        __weak __typeof(self)weakSelf = self;
        [self.assetWriter finishWritingWithCompletionHandler:^(){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    handle(strongSelf.movieURL, nil);
                });
            } else {
                handle(nil, strongSelf.assetWriter.error);
            }
            strongSelf.assetWriter = nil;
        }];
    });
}

- (void)writeData:(AVCaptureConnection *)connection video:(AVCaptureConnection*)video audio:(AVCaptureConnection *)audio buffer:(CMSampleBufferRef)buffer {
    
    CFRetain(buffer);
    dispatch_async(self.videoWriteQueue, ^{
        if (connection == video){
            if (!self.readyToRecordVideo){
                self.readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
            }
            if ([self inputsReadyToRecord]){
                [self writeSampleBuffer:buffer ofType:AVMediaTypeVideo];
            }
        } else if (connection == audio){
            if (!self.readyToRecordAudio){
                self.readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
            }
            if ([self inputsReadyToRecord]){
                [self writeSampleBuffer:buffer ofType:AVMediaTypeAudio];
            }
        }
        CFRelease(buffer);
    });
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType {
    
    if (self.assetWriter.status == AVAssetWriterStatusUnknown){
        if ([self.assetWriter startWriting]){
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            NSLog(@"%@", self.assetWriter.error);
        }
    }
    if (self.assetWriter.status == AVAssetWriterStatusWriting){
        if (mediaType == AVMediaTypeVideo){
            if (!self.videoInput.readyForMoreMediaData){
                return;
            }
            if (![self.videoInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"%@", self.assetWriter.error);
            }
        } else if (mediaType == AVMediaTypeAudio){
            if (!self.audioInput.readyForMoreMediaData){
                return;
            }
            if (![self.audioInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"%@", self.assetWriter.error);
            }
        }
    }
}


#pragma mark - Private

// 音频源数据写入配置
- (NSError *)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
//    size_t aclSize = 0;
//    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
//    const AudioChannelLayout *channelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription,&aclSize);
//    NSData *dataLayout = aclSize > 0 ? [NSData dataWithBytes:channelLayout length:aclSize] : [NSData data];
//    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
//                               AVSampleRateKey: @(currentASBD->mSampleRate),
//                               AVChannelLayoutKey: dataLayout,
//                               AVNumberOfChannelsKey: @(currentASBD->mChannelsPerFrame),
//                               AVEncoderBitRatePerChannelKey: @(64000)};
    
    // 音频设置
    NSDictionary *settings = @{
                               AVEncoderBitRatePerChannelKey : @(28000),
                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                               AVNumberOfChannelsKey : @(1),
                               AVSampleRateKey : @(22050)
                               };
    

    if ([self.assetWriter canApplyOutputSettings:settings forMediaType: AVMediaTypeAudio]){
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings:settings];
        self.audioInput.expectsMediaDataInRealTime = YES;
        if ([self.assetWriter canAddInput:self.audioInput]){
            [self.assetWriter addInput:self.audioInput];
        } else {
            return self.assetWriter.error;
        }
    } else {
        return self.assetWriter.error;
    }
    return nil;
}

// 视频源数据写入配置
- (NSError *)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    
//    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
//
//    //写入视频大小
//    NSUInteger numPixels = dimensions.width * dimensions.height;
//    //每像素比特
//    CGFloat bitsPerPixel = numPixels < (640 * 480) ? 4.05 : 11.0;
//    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
//
//
//    // 码率和帧率设置
//    NSDictionary *compression = @{AVVideoAverageBitRateKey: @(bitsPerSecond),
//                                  AVVideoMaxKeyFrameIntervalKey: @(15),
//                                  AVVideoExpectedSourceFrameRateKey : @(15),
//                                  AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
//
//    NSDictionary *settings;
//    if (@available(iOS 11.0, *)) {
//        settings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
//                     AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
//                     AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
//                     AVVideoCompressionPropertiesKey: compression};
//    } else {
//        settings = @{AVVideoCodecKey: AVVideoCodecH264,
//                     AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
//                     AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
//                     AVVideoCompressionPropertiesKey: compression};
//    }
    
    CGFloat kScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat kScreenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //写入视频大小
    NSInteger numPixels = kScreenWidth * kScreenHeight;
    
    //每像素比特
    CGFloat bitsPerPixel = 12.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(15),
                                             AVVideoMaxKeyFrameIntervalKey : @(15),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    CGFloat width = kScreenHeight;
    CGFloat height = kScreenWidth;
    if (TL_IS_IPHONE_XR) {
        width = kScreenHeight - 146;
        height = kScreenWidth;
    }
    //视频属性
    NSDictionary *settings = @{
                               AVVideoCodecKey : AVVideoCodecTypeH264,
                               AVVideoWidthKey : @(width * 2),
                               AVVideoHeightKey : @(height * 2),
                               AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                               AVVideoCompressionPropertiesKey : compressionProperties
                               };
    
    if ([self.assetWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]){
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        self.videoInput.expectsMediaDataInRealTime = YES;
        self.videoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([self.assetWriter canAddInput:self.videoInput]){
            [self.assetWriter addInput:self.videoInput];
        } else {
            return self.assetWriter.error;
        }
    } else {
        return self.assetWriter.error;
    }
    return nil;
}

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.currentOrientation];
    CGFloat angleOffset;
    if (self.currentDevice.position == AVCaptureDevicePositionBack) {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    } else {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
    }
    return angle;
}

- (NSURL *)makeMovieURL {
    NSUUID *uuid = [NSUUID new];
    NSString *fileName = [uuid.UUIDString stringByAppendingPathExtension:self.type];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

- (BOOL)inputsReadyToRecord {
    return self.readyToRecordVideo && self.readyToRecordAudio;
}

/**
 获取视频第一帧的图片
 */
- (void)fetchMovieFirstNeedleHandler:(void (^)(UIImage *movieImage))handler {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.movieURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            dispatch_async(dispatch_get_main_queue(), ^{
                !handler ? : handler(thumbImg);
            });
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
    [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

@end
