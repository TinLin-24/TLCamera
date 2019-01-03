//
//  UIAlertController+TLExtension.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (TLExtension)

- (void)tl_addActionWithTitle:(nullable NSString *)title style:(UIAlertActionStyle)style handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (void)tl_showWithViewController:(nullable UIViewController *)viewController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

@end
