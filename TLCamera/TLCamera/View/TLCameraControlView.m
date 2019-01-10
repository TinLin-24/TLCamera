//
//  TLCameraControlView.m
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLCameraControlView.h"

@interface TLCameraControlView (){
    struct {
        unsigned int didFlashLightAction : 1;
        unsigned int didTorchLightAction : 1;
        unsigned int didSwicthCameraAction : 1;
        unsigned int didAutoFocusAndExposureAction : 1;
        unsigned int didFocusAction : 1;
        unsigned int didExposAction : 1;
        unsigned int didZoomAction : 1;
        unsigned int didCancelAction : 1;
        unsigned int didTakePhotoAction : 1;
        unsigned int didStopRecordVideoAction : 1;
        unsigned int didStartRecordVideoAction : 1;
        unsigned int didPreviewAction : 1;
        unsigned int didDoneAction : 1;
    }_delegateFlags;
}

@end

@implementation TLCameraControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    TLShutterButton *shutterBtn = [[TLShutterButton alloc] initWithFrame:CGRectMake(0, 0, 125.f, 125.f) EnableType:TLEnableTypeAll];
    shutterBtn.center = CGPointMake(self.width/2, self.height-125.f);
    __weak __typeof(self)weakSelf = self;
    shutterBtn.didTap = ^(TLShutterButton *sender) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(takePhotoAction:)]) {
            [strongSelf.delegate takePhotoAction:strongSelf];
        }
    };
    
    shutterBtn.didStartLongPress = ^(TLShutterButton *sender) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
            [strongSelf.delegate startRecordVideoAction:strongSelf];
        }
    };
    
    shutterBtn.didEndLongPress = ^(TLShutterButton *sender) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
            [strongSelf.delegate stopRecordVideoAction:strongSelf];
        }
    };
    
    [self addSubview:shutterBtn];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TLMainScreenWidth, 20.f)];
    textLabel.top = shutterBtn.top - 25.f;
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel setText:@"轻触拍照，长按摄像"];
    [textLabel setTextColor:[UIColor whiteColor]];
    [textLabel setFont:TLFont(16.f, NO)];
    [self addSubview:textLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.tag = 1000;
    [self addSubview:cancelBtn];
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn setImage:TLImageNamed(@"ic_switch") forState:UIControlStateNormal];
    switchBtn.tag = 1001;
    [self addSubview:switchBtn];
    
    UIButton *torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [torchBtn setImage:TLImageNamed(@"ic_torch_off") forState:UIControlStateNormal];
    [torchBtn setImage:TLImageNamed(@"ic_torch_on") forState:UIControlStateSelected];
    torchBtn.tag = 1002;
    [self addSubview:torchBtn];
    
    UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lightBtn setImage:TLImageNamed(@"ic_light_off") forState:UIControlStateNormal];
    [lightBtn setImage:TLImageNamed(@"ic_light_on") forState:UIControlStateSelected];
    lightBtn.tag = 1003;
    [self addSubview:lightBtn];
    
    UIButton *autofocusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [autofocusBtn setImage:TLImageNamed(@"ic_auto_focus_exposure") forState:UIControlStateNormal];
    autofocusBtn.tag = 1004;
    [self addSubview:autofocusBtn];
    
    NSArray *btnArray = @[cancelBtn,switchBtn,torchBtn,lightBtn,autofocusBtn];
    CGFloat width = TLMainScreenWidth/btnArray.count;
    CGFloat height = 44.f;
    CGFloat y = TLTopMargin(15.f);
    for (UIButton *btn in btnArray) {
        CGFloat x = (btn.tag - 1000)*width;
        btn.frame = CGRectMake(x, y, width, height);
        [btn addTarget:self action:@selector(handleBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)handleBtnEvent:(UIButton *)sender {
    switch (sender.tag) {
        case 1000:
        {
            
            break;
        }
        case 1001:
        {
            if (_delegateFlags.didSwicthCameraAction) {
                [self.delegate switchCameraAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1002:
        {
            if (_delegateFlags.didTorchLightAction) {
                [self.delegate torchLightAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1003:
        {
            if (_delegateFlags.didFlashLightAction) {
                [self.delegate flashLightAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1004:
        {
            if (_delegateFlags.didAutoFocusAndExposureAction) {
                [self.delegate autoFocusAndExposureAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
    }
}

#pragma mark - Setter

- (void)setDelegate:(id<TLCameraControlViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.didFlashLightAction = [delegate respondsToSelector:@selector(flashLightAction:handle:)];
    _delegateFlags.didTorchLightAction = [delegate respondsToSelector:@selector(torchLightAction:handle:)];
    _delegateFlags.didSwicthCameraAction = [delegate respondsToSelector:@selector(switchCameraAction:handle:)];
    _delegateFlags.didAutoFocusAndExposureAction = [delegate respondsToSelector:@selector(autoFocusAndExposureAction:handle:)];
    _delegateFlags.didFocusAction = [delegate respondsToSelector:@selector(focusAction:point:handle:)];
    _delegateFlags.didExposAction = [delegate respondsToSelector:@selector(exposAction:point:handle:)];
    _delegateFlags.didZoomAction = [delegate respondsToSelector:@selector(zoomAction:factor:)];
    _delegateFlags.didCancelAction = [delegate respondsToSelector:@selector(cancelAction:)];
    _delegateFlags.didTakePhotoAction = [delegate respondsToSelector:@selector(takePhotoAction:)];
    _delegateFlags.didStopRecordVideoAction = [delegate respondsToSelector:@selector(stopRecordVideoAction:)];
    _delegateFlags.didStartRecordVideoAction = [delegate respondsToSelector:@selector(startRecordVideoAction:)];
    _delegateFlags.didPreviewAction = [delegate respondsToSelector:@selector(previewAction:)];
    _delegateFlags.didDoneAction = [delegate respondsToSelector:@selector(doneAction:)];
}

@end
