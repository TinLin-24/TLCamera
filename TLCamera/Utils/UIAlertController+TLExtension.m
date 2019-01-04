//
//  UIAlertController+TLExtension.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "UIAlertController+TLExtension.h"

@implementation UIAlertController (TLExtension)

- (void)tl_addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:handler];
    [self addAction:action];
}

- (void)tl_showWithViewController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^ _Nullable)(void))completion {
    if (viewController == nil || ![viewController isKindOfClass:[UIViewController class]]) {
        viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    [viewController presentViewController:self animated:flag completion:completion];
}

@end
