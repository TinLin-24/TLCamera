//
//  TLShutterButton.h
//  Demo
//
//  Created by Mac on 2018/12/29.
//  Copyright © 2018 TinLin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TLEnableType) {
    TLEnableTypeTap = 0x0001,
    TLEnableTypeLongPress = 0x0002,
    TLEnableTypeAll   = TLEnableTypeTap | TLEnableTypeLongPress
};

@interface TLShutterButton : UIControl

// 是否允许点击
@property (nonatomic, assign, readonly)BOOL enableTap;

// 是否允许长按
@property (nonatomic, assign, readonly)BOOL enableLongPress;

// 长按的最长时间
@property (nonatomic, assign)NSTimeInterval longPressMaxDuration;

// 圆环进度条的颜色
@property (nonatomic, strong)UIColor *progressColor;

// 点击回调
@property (nonatomic, copy)void (^didTap)(TLShutterButton *sender);

// 开始长按回调
@property (nonatomic, copy)void (^didStartLongPress)(TLShutterButton *sender);

// 长按结束回调
@property (nonatomic, copy)void (^didEndLongPress)(TLShutterButton *sender);

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame EnableType:(TLEnableType)type NS_DESIGNATED_INITIALIZER;

@end
