//
//  TLConstInline.h
//  RiceShop
//
//  Created by TinLin on 2018/11/28.
//  Copyright © 2018 eseaHealth. All rights reserved.
//

#ifndef TLConstInline_h
#define TLConstInline_h

/// 适配 iPhone X 距离顶部的距离
static inline CGFloat TLTopMargin(CGFloat pt){
    return TL_IS_ALIEN_SCREEN ? (pt + 24) : (pt);
}

/// 适配 iPhone X 距离底部的距离
static inline CGFloat TLBottomMargin(CGFloat pt){
    return TL_IS_ALIEN_SCREEN ? (pt + 34) : (pt);
}

#endif /* TLConstInline_h */
