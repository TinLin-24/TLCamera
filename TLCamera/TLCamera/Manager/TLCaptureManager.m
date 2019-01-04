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

@property(nonatomic, strong, readwrite) AVCaptureDeviceInput *videoDeviceInput;

@property(nonatomic, strong, readwrite) AVCaptureDeviceInput *audioDeviceInput;

@property(nonatomic, strong, readwrite) AVCaptureConnection *videoConnection;

@property(nonatomic, strong, readwrite) AVCaptureConnection *audioConnection;

@property(nonatomic, strong, readwrite) AVCaptureVideoDataOutput *videoDataOutput;

@property(nonatomic, strong, readwrite) AVCaptureAudioDataOutput *audioDataOutput;

@property(nonatomic, strong) dispatch_queue_t videoQueue;

@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property(nonatomic, strong) AVCapturePhotoOutput *photoOutput;

@property(nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *previewLayer;

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
    self.videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backDevice error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput Video ERROR:%@",error);
        return;
    }
    if ([self.captureSession canAddInput:self.videoDeviceInput]) {
        [self.captureSession addInput:self.videoDeviceInput];
    }
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
}

- (void)setupAudio {
    NSError *error = nil;
    self.audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput Audio ERROR:%@",error);
        return;
    }
    if ([self.captureSession canAddInput:self.audioDeviceInput]) {
        [self.captureSession addInput:self.audioDeviceInput];
    }
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        [self.captureSession addOutput:self.audioDataOutput];
    }
    
    self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
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
        if (@available(iOS 11.0, *)) {
            outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
        } else {
            outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        }
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
    if (@available(iOS 10.0, *)) {
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
                //[self previewPhotoWithImage:image];
            }
        }];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(nonnull AVCapturePhoto *)photo error:(nullable NSError *)error {
    NSData *data = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:data];
    NSLog(@"image:%@", image);
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
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
        _frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    }
    return _frontDevice;
}

- (AVCaptureDevice *)backDevice {
    if (!_backDevice) {
        _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if (!_backDevice) {
            // If the back dual camera is not available, default to the back wide angle camera.
            _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
            // In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
            if (!_backDevice) {
                _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
            }
        }
    }
    return _backDevice;
}

- (AVCaptureDevice *)audioDevice {
    if (!_audioDevice) {
        _audioDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInMicrophone mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
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
