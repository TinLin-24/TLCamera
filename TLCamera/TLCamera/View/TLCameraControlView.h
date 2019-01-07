//
//  TLCameraControlView.h
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLCameraControlView;

@protocol TLCameraControlViewDelegate <NSObject>
@optional;

/// 闪光灯
- (void)flashLightAction:(TLCameraControlView *)controlView handle:(void(^)(NSError *error))handle;

/// 补光
- (void)torchLightAction:(TLCameraControlView *)controlView handle:(void(^)(NSError *error))handle;

/// 转换摄像头
- (void)switchCameraAction:(TLCameraControlView *)controlView handle:(void(^)(NSError *error))handle;

/// 自动聚焦曝光
- (void)autoFocusAndExposureAction:(TLCameraControlView *)controlView handle:(void(^)(NSError *error))handle;

/// 聚焦
- (void)focusAction:(TLCameraControlView *)controlView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/// 曝光
- (void)exposAction:(TLCameraControlView *)controlView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/// 缩放
- (void)zoomAction:(TLCameraControlView *)controlView factor:(CGFloat)factor;

/// 取消
- (void)cancelAction:(TLCameraControlView *)controlView;

/// 拍照
- (void)takePhotoAction:(TLCameraControlView *)controlView;

/// 停止录制视频
- (void)stopRecordVideoAction:(TLCameraControlView *)controlView;

/// 开始录制视频
- (void)startRecordVideoAction:(TLCameraControlView *)controlView;

/// 点击预览和编辑
- (void)previewAction:(TLCameraControlView *)controlView;

/// 完成预览和编辑
- (void)doneAction:(TLCameraControlView *)controlView;

@end

@interface TLCameraControlView : UIView

@property(nonatomic, weak) id<TLCameraControlViewDelegate> delegate;

@end
