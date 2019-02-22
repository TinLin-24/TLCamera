//
//  TLProgressView.m
//  TLCamera
//
//  Created by Mac on 2019/2/18.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import "TLProgressView.h"

@interface TLProgressView ()

@property(nonatomic, readwrite, strong) CAShapeLayer *progressLayer;

@end

@implementation TLProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    CAShapeLayer *progressLayer = [CAShapeLayer layer];

    CGFloat lineWidth = self.width;
    CGFloat radius = lineWidth/2;
    CGPoint center = CGPointMake(radius, radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    progressLayer.path = path.CGPath;
    progressLayer.lineWidth = lineWidth;
    progressLayer.lineCap = kCALineCapButt;
    progressLayer.strokeColor = [UIColor redColor].CGColor;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeStart = 0.f;
    progressLayer.strokeEnd = 0.25f;
    [self.layer addSublayer:progressLayer];
    
    self.progressLayer = progressLayer;
}

@end
