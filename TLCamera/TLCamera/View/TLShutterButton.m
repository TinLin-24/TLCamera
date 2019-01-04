//
//  TLShutterButton.m
//  Demo
//
//  Created by Mac on 2018/12/29.
//  Copyright © 2018 TinLin. All rights reserved.
//

#import "TLShutterButton.h"

// 动画时长
static const NSTimeInterval kAnimationDuration = 0.33f;
// 区分Animation的Key
static NSString *kAnimationKey = @"kAnimationKey";
// 背景Animation的Key
static NSString *kAnimationBackground = @"backgroundLayer";
// 进度Animation的Key
static NSString *kAnimationProgress = @"progressLayer";

@interface TLShutterButton ()<CAAnimationDelegate>

// 是否允许点击
@property (nonatomic, assign, readwrite)BOOL enableTap;

// 是否允许长按
@property (nonatomic, assign, readwrite)BOOL enableLongPress;

//
@property (nonatomic, strong)CAShapeLayer *centerLayer;

//
@property (nonatomic, strong)CAShapeLayer *backgroundLayer;

//
@property (nonatomic, strong)CAShapeLayer *progressLayer;

//
@property (nonatomic, strong)UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation TLShutterButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.longPressMaxDuration = 10;
        self.enableTap = YES;
        self.enableLongPress = YES;
        
        [self _setup];
        [self _setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame EnableType:(TLEnableType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.longPressMaxDuration = 10;
        
        switch (type) {
            case TLEnableTypeTap: {
                self.enableTap = YES;
                self.enableLongPress = NO;
                break;
            }
            case TLEnableTypeLongPress: {
                self.enableTap = NO;
                self.enableLongPress = YES;
                break;
            }
            case TLEnableTypeAll: {
                self.enableTap = YES;
                self.enableLongPress = YES;
                break;
            }
        }
        
        [self _setup];
        [self _setupSubViews];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor clearColor];
    
//    self.layer.borderColor = [UIColor blackColor].CGColor;
//    self.layer.borderWidth = 1.f;
    
    if (self.enableLongPress) {
        [self addGestureRecognizer:self.longPressGestureRecognizer];
    }
    if (self.enableTap) {
        [self addTarget:self action:@selector(_didTap:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_setupSubViews {
    [self.layer addSublayer:self.backgroundLayer];
    
    [self.layer addSublayer:self.progressLayer];
    
    [self.layer addSublayer:self.centerLayer];
}

#pragma mark - Action

- (void)_didTap:(TLShutterButton *)sender {
    !self.didTap ? : self.didTap(self);
}

- (void)_didLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
        {
            NSLog(@"UIGestureRecognizerStateBegan");
            [self _didStartLongPress];
        }
            break;
            case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
            [self _didEndLongPress];
        }
            break;
            case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"UIGestureRecognizerStateCancelled");
            [self _didEndLongPress];
        }
            break;
        default:
            //NSLog(@"%zd",gestureRecognizer.state);
            break;
    }
}

- (void)_didStartLongPress {
    CABasicAnimation *animationB = [self _makeBackgroundLayerAnimation:YES];
    animationB.delegate = self;
    [animationB setValue:kAnimationBackground forKey:kAnimationKey];
    [self.backgroundLayer addAnimation:animationB forKey:nil];
    self.backgroundLayer.path = (__bridge CGPathRef _Nullable)(animationB.toValue);
    
    CABasicAnimation *animationC = [self _makeCenterLayerAnimation:YES];
    [self.centerLayer addAnimation:animationC forKey:nil];
    self.centerLayer.path = (__bridge CGPathRef _Nullable)(animationC.toValue);
}

- (void)_didEndLongPress {
    // 这里要删除backgroundLayer的所有动画，防止CAAnimationDelegate里面调用录制动画
    [self.backgroundLayer removeAllAnimations];
    
    CABasicAnimation *animationB = [self _makeBackgroundLayerAnimation:NO];
    [self.backgroundLayer addAnimation:animationB forKey:nil];
    self.backgroundLayer.path = (__bridge CGPathRef _Nullable)(animationB.toValue);
    
    CABasicAnimation *animationC = [self _makeCenterLayerAnimation:NO];
    [self.centerLayer addAnimation:animationC forKey:nil];
    self.centerLayer.path = (__bridge CGPathRef _Nullable)(animationC.toValue);
    
    [self.progressLayer removeAllAnimations];
    
    !self.didEndLongPress ? : self.didEndLongPress(self);
}

- (void)_showRecordingAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setValue:kAnimationProgress forKey:kAnimationKey];
    animation.delegate = self;
    animation.duration = self.longPressMaxDuration;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.progressLayer addAnimation:animation forKey:@"animation"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    TLLogFunc;
    NSString *key = [anim valueForKey:kAnimationKey];
    if ([key isEqualToString:kAnimationProgress])  {
        !self.didStartLongPress ? : self.didStartLongPress(self);
    }
    NSLog(@"%@",key);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }

    NSString *key = [anim valueForKey:kAnimationKey];
    if ([key isEqualToString:kAnimationBackground]) {
        [self _showRecordingAnimation];
    }
    else if ([key isEqualToString:kAnimationProgress])  {
        NSLog(@"end");
        // 取消手势
        self.longPressGestureRecognizer.enabled = NO;
        self.longPressGestureRecognizer.enabled = YES;
    }
}

#pragma mark - 辅助方法

/**
 获取backgroundLayer默认的Rect
 */
- (CGRect)_fetchBackgroundDefaultRect {
    return CGRectInset(self.bounds, 20.f, 20.f);
}

/**
 获取触发长按后backgroundLayer的Rect
 */
- (CGRect)_fetchBackgroundChangedRect {
    return self.bounds;
}

- (CABasicAnimation *)_makeBackgroundLayerAnimation:(BOOL)isNormal {
    UIBezierPath *startPath = [UIBezierPath bezierPathWithCGPath:self.backgroundLayer.path];
    CGRect rect = isNormal ? [self _fetchBackgroundChangedRect] : [self _fetchBackgroundDefaultRect];
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    return [self _makeBasicAnimationWithStartPath:startPath EndPath:endPath];
}

- (CABasicAnimation *)_makeCenterLayerAnimation:(BOOL)isNormal {
    UIBezierPath *startPath = [UIBezierPath bezierPathWithCGPath:self.centerLayer.path];
    CGRect rect = [self _fetchBackgroundDefaultRect];
    CGFloat d = isNormal ? 15 : 10;
    rect = CGRectInset(rect, d, d);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    return [self _makeBasicAnimationWithStartPath:startPath EndPath:endPath];
}

- (CABasicAnimation *)_makeBasicAnimationWithStartPath:(UIBezierPath *)startPath
                                               EndPath:(UIBezierPath *)endPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = kAnimationDuration;
    animation.fromValue = (__bridge id _Nullable)startPath.CGPath;
    animation.toValue = (__bridge id _Nullable)endPath.CGPath;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    return animation;
}

#pragma mark - Setter

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.progressLayer.strokeColor = progressColor.CGColor;
}

#pragma mark - Getter

- (CAShapeLayer *)centerLayer {
    if (!_centerLayer) {
        _centerLayer = [CAShapeLayer layer];
        CGRect frame = CGRectInset([self _fetchBackgroundDefaultRect], 10, 10);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:frame];
        _centerLayer.path = path.CGPath;
        _centerLayer.fillColor = [UIColor colorWithWhite:1.f alpha:.8].CGColor;
    }
    return _centerLayer;
}

- (CAShapeLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:[self _fetchBackgroundDefaultRect]];
        _backgroundLayer.path = path.CGPath;
        _backgroundLayer.fillColor = [UIColor colorWithWhite:1.f alpha:.5].CGColor;
    }
    return _backgroundLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        CGFloat lineWidth = 7.f;
        CGFloat radius = self.width/2;
        CGPoint center = CGPointMake(radius, radius);
        radius -= lineWidth/2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        _progressLayer.path = path.CGPath;
        _progressLayer.lineWidth = lineWidth;
        _progressLayer.lineCap = kCALineCapButt;
        _progressLayer.strokeColor = [UIColor colorWithHexString:@"#00D76E"].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeStart = 0.f;
        _progressLayer.strokeEnd = 0.f;
    }
    return _progressLayer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didLongPressGestureRecognizer:)];
        gestureRecognizer.numberOfTouchesRequired = 1;
        gestureRecognizer.minimumPressDuration = .5f;
        _longPressGestureRecognizer = gestureRecognizer;
    }
    return _longPressGestureRecognizer;
}

@end
