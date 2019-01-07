//
//  TLCameraControlView.m
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLCameraControlView.h"

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
            if (self.delegate && [self.delegate respondsToSelector:@selector(swicthCameraAction:handle:)]) {
                [self.delegate swicthCameraAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1002:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(torchLightAction:handle:)]) {
                [self.delegate torchLightAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1003:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(flashLightAction:handle:)]) {
                [self.delegate flashLightAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
        case 1004:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(autoFocusAndExposureAction:handle:)]) {
                [self.delegate autoFocusAndExposureAction:self handle:^(NSError *error) {
                    
                }];
            }
            break;
        }
    }
}

@end
