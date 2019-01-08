//
//  TLCaptureManager.m
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLCaptureManager.h"

@interface TLCaptureManager ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCapturePhotoCaptureDelegate>

@property(nonatomic, strong) TLMovieWriterManager *movieWriterManager;

@property(nonatomic, strong) TLMotionManager *motionManager;

@property(nonatomic, strong) AVCaptureSession *captureSession;

@property(nonatomic, strong, readwrite) AVCaptureDevice *frontDevice;

@property(nonatomic, strong, readwrite) AVCaptureDevice *backDevice;

@property(nonatomic, strong, readwrite) AVCaptureDevice *audioDevice;

@property(nonatomic, strong, readwrite) AVCaptureConnection *videoConnection;

@property(nonatomic, strong, readwrite) AVCaptureConnection *audioConnection;

@property(nonatomic, strong, readwrite) AVCaptureDeviceInput *videoDeviceInput;

@property(nonatomic, strong) dispatch_queue_t videoQueue;

@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property(nonatomic, strong) AVCapturePhotoOutput *photoOutput API_AVAILABLE(ios(10.0));

@property(nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *previewLayer;

// 标记是否在录制中
@property(nonatomic, assign) BOOL recording;

@end

@implementation TLCaptureManager

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videoQueue = dispatch_queue_create("com.tinlin.capture", DISPATCH_QUEUE_SERIAL);
        [self configure];
    }
    return self;
}

#pragma mark - Private

- (void)configure {
    [self setupVideo];
    [self setupAudio];
    [self setupPhotoOutput];
    [self setupPreviewLayer];
}

- (void)setupVideo {
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backDevice error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput Video ERROR:%@",error);
        return;
    }
    if ([self.captureSession canAddInput:videoDeviceInput]) {
        [self.captureSession addInput:videoDeviceInput];
    }
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    [videoDataOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.captureSession canAddOutput:videoDataOutput]) {
        [self.captureSession addOutput:videoDataOutput];
    }
    self.videoDeviceInput = videoDeviceInput;
    self.videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
}

- (void)setupAudio {
    NSError *error = nil;
    AVCaptureDeviceInput *audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput Audio ERROR:%@",error);
        return;
    }
    if ([self.captureSession canAddInput:audioDeviceInput]) {
        [self.captureSession addInput:audioDeviceInput];
    }
    AVCaptureAudioDataOutput *audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioDataOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.captureSession canAddOutput:audioDataOutput]) {
        [self.captureSession addOutput:audioDataOutput];
    }
    
    self.audioConnection = [audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void)setupPhotoOutput {
    if (@available(iOS 10.0, *)) {
        self.photoOutput = [[AVCapturePhotoOutput alloc] init];
        if ([self.captureSession canAddOutput:self.photoOutput]) {
            [self.captureSession addOutput:self.photoOutput];
        }
    } else {
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings;
        outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        [self.stillImageOutput setOutputSettings:outputSettings];
        if ([self.captureSession canAddOutput:self.stillImageOutput]) {
            [self.captureSession addOutput:self.stillImageOutput];
        }
    }
    
}

- (void)setupPreviewLayer {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    // 填充模式
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

#pragma mark - Public

- (void)startRunningSession {
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopRunningSession {
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)takePicture {
    if (@available(iOS 11.0, *)) {
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];;
        [settings setFlashMode:AVCaptureFlashModeOff];
        [self.photoOutput capturePhotoWithSettings:settings delegate:self];
    } else {
        //根据设备输出获得连接
        AVCaptureConnection *captureConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        //根据连接取得设备输出的数据
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:imageData];
                if (self.delegate && [self.delegate respondsToSelector:@selector(finishTakePicture:)]) {
                    [self.delegate finishTakePicture:image];
                }
                //[self previewPhotoWithImage:image];
            }
        }];
    }
}

- (void)startVideoRecorder {
    self.recording = YES;
    self.movieWriterManager.currentDevice = self.backDevice;
    self.movieWriterManager.currentOrientation = [self currentVideoOrientation];

    [self.movieWriterManager start:^(NSError * _Nonnull error) {
        NSLog(@"startVideoRecorder:%@",error);
    }];
}

- (void)stopVideoRecorder {
    self.recording = NO;
    __weak __typeof(self)weakSelf = self;
    [self.movieWriterManager stop:^(NSURL *url, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"stopVideoRecorder:%@",url);
        UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, nil, nil, nil);
        if (strongSelf.delegate && [strongSelf respondsToSelector:@selector(finishRecordVideo:videoPathUrl:)]) {
            [strongSelf.delegate finishRecordVideo:nil videoPathUrl:url];
        }
    }];
}

- (void)switchCamera {
    AVCaptureDevice *currentDevice = [self.videoDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    AVCaptureDevice *toChangeDevice;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangeDevice = self.backDevice;
    } else {
        toChangeDevice = self.frontDevice;
    }
    if (toChangeDevice == nil) {
        return;
    }
    NSError *error;
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
    // 改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    // 移除原有输入对象
    [self.captureSession removeInput:self.videoDeviceInput];
    // 添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.videoDeviceInput = toChangeDeviceInput;
    } else {
        [self.captureSession addInput:self.videoDeviceInput];
    }
    // 提交会话配置
    [self.captureSession commitConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.recording) {
        [self.movieWriterManager writeData:connection video:self.videoConnection audio:self.audioConnection buffer:sampleBuffer];
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(nonnull AVCapturePhoto *)photo error:(nullable NSError *)error  API_AVAILABLE(ios(11.0)){
    NSData *imageData = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:imageData];
    NSLog(@"image:%@", image);
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - Section

// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

#pragma mark - Getter

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureDevice *)frontDevice {
    if (!_frontDevice) {
        // 前置摄像头
        if (@available(iOS 10.0, *)) {
            _frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        } else {
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *device in devices) {
                if (device.position == AVCaptureDevicePositionFront) {
                    _frontDevice = device;
                }
            }
        }
    }
    return _frontDevice;
}

- (AVCaptureDevice *)backDevice {
    if (!_backDevice) {
        if (@available(iOS 10.2, *)) {
            // 后置双摄像头
            _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
            if (!_backDevice) {
                // 如果后置双摄像头不可用，则默认为后置广角摄像头。
                _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
            }
            if (!_backDevice) {
                // 在某些用户打破手机的情况下，后置广角相机无法使用。 在这种情况下，我们应默认为前广角相机。
                _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
            }
        } else {
            _backDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
    }
    return _backDevice;
}

- (AVCaptureDevice *)audioDevice {
    if (!_audioDevice) {
        _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    return _audioDevice;
}

- (TLMovieWriterManager *)movieWriterManager {
    if (!_movieWriterManager) {
        _movieWriterManager = [[TLMovieWriterManager alloc] initWithFileType:TLAVFileTypeMP4];
    }
    return _movieWriterManager;
}

- (TLMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[TLMotionManager alloc] init];
    }
    return _motionManager;
}

@end
