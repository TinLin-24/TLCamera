//
//  TLCameraConfig.h
//  TLCamera
//
//  Created by Mac on 2019/1/4.
//  Copyright © 2019 tinlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLCameraConfig : NSObject

@property(nonatomic, strong) UIColor *progressColor;

@property(nonatomic, assign) TLAVFileType fileType;

@property(nonatomic, assign) BOOL enableTakePhoto;

@property(nonatomic, assign) BOOL enableVideoRecord;

@end
