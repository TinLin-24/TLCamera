//
//  TLMarcos.h
//  RiceShop
//
//  Created by TinLin on 2018/11/28.
//  Copyright © 2018 eseaHealth. All rights reserved.
//

#ifndef TLMarcos_h
#define TLMarcos_h

///------
/// Block
///------
typedef void (^VoidBlock)(void);
typedef BOOL (^BoolBlock)(void);
typedef int  (^IntBlock) (void);
typedef id   (^IDBlock)  (void);

typedef void (^VoidBlock_int)(int);
typedef BOOL (^BoolBlock_int)(int);
typedef int  (^IntBlock_int) (int);
typedef id   (^IDBlock_int)  (int);

typedef void (^VoidBlock_string)(NSString *);
typedef BOOL (^BoolBlock_string)(NSString *);
typedef int  (^IntBlock_string) (NSString *);
typedef id   (^IDBlock_string)  (NSString *);

typedef void (^VoidBlock_id)(id);
typedef BOOL (^BoolBlock_id)(id);
typedef int  (^IntBlock_id) (id);
typedef id   (^IDBlock_id)  (id);

/// 类型相关
#define TL_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define TL_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define TL_IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

/// 屏幕尺寸相关
#define TL_SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define TL_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define TL_SCREEN_BOUNDS ([[UIScreen mainScreen] bounds])
#define TL_SCREEN_MAX_LENGTH (MAX(TL_SCREEN_WIDTH, TL_SCREEN_HEIGHT))
#define TL_SCREEN_MIN_LENGTH (MIN(TL_SCREEN_WIDTH, TL_SCREEN_HEIGHT))

/// 手机类型相关
#define TL_IS_IPHONE_4_OR_LESS  (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH  < 568.0)
#define TL_IS_IPHONE_5          (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 568.0)
#define TL_IS_IPHONE_6          (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 667.0)
#define TL_IS_IPHONE_6P         (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 736.0)
#define TL_IS_IPHONE_X_OR_XS    (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 812.0)
#define TL_IS_IPHONE_XR         (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 896.0)
#define TL_IS_IPHONE_Xs_Max     (TL_IS_IPHONE && TL_SCREEN_MAX_LENGTH == 896.0)

/// 是不是异形屏
#define TL_IS_ALIEN_SCREEN      (TL_IS_IPHONE_X_OR_XS || TL_IS_IPHONE_XR || TL_IS_IPHONE_Xs_Max)

/// 导航条高度
#define TL_APPLICATION_TOP_BAR_HEIGHT (TL_IS_ALIEN_SCREEN ? 88.0f : 64.0f)
/// tabBar高度
#define TL_APPLICATION_TAB_BAR_HEIGHT (TL_IS_ALIEN_SCREEN ? 83.0f : 49.0f)
/// 工具条高度 (常见的高度)
#define TL_APPLICATION_TOOL_BAR_HEIGHT_44  44.0f
#define TL_APPLICATION_TOOL_BAR_HEIGHT_49  49.0f
/// 状态栏高度
#define TL_APPLICATION_STATUS_BAR_HEIGHT (TL_IS_ALIEN_SCREEN ? 44.0f : 20.0f)


// 适配AF
#ifndef TARGET_OS_IOS

#define TARGET_OS_IOS TARGET_OS_IPHONE

#endif

#ifndef TARGET_OS_WATCH

#define TARGET_OS_WATCH 0

#endif


// 输出日志 (格式: [时间] [哪个方法] [哪行] [输出内容])
#ifdef DEBUG
#define NSLog(format, ...) printf("\n[%s] %s [第%d行] 💕 %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

// 日记输出宏
#ifdef DEBUG // 调试状态, 打开LOG功能
#define TLLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define TLLog(...)
#endif

// 打印方法
#define TLLogFunc TLLog(@"%s", __func__)


// 打印请求错误信息
#define TLLogErrorMessage  TLLog(@"错误请求日志-----【 %@ 】--【 %@ 】",[self class] , error.TL_message)


// KVO获取监听对象的属性 有自动提示
// 宏里面的#，会自动把后面的参数变成c语言的字符串
#define TLKeyPath(objc,keyPath) @(((void)objc.keyPath ,#keyPath))

/// 设置系统的字体大小（YES：粗体 NO：常规）
#define TLFont(__size__,__bold__) ((__bold__)?([UIFont boldSystemFontOfSize:__size__]):([UIFont systemFontOfSize:__size__]))

// 颜色
#define TLColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 颜色+透明度
#define TLAlphaColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

// Hex 颜色
#define TLHexColor(__hexStr) [UIColor colorWithHexString:__hexStr]

// 随机色
#define TLRandomColor TLColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
// 根据rgbValue获取值
#define TLColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 是否为iOS7+
#define TLIOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// 是否为4inch
#define TLFourInch ([UIScreen mainScreen].bounds.size.height == 568.0)

// 屏幕总尺寸
#define TLMainScreenBounds  [UIScreen mainScreen].bounds
#define TLMainScreenHeight  [UIScreen mainScreen].bounds.size.height
#define TLMainScreenWidth   [UIScreen mainScreen].bounds.size.width

// IOS版本
#define TLIOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define TL_iOS7_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
#define TL_iOS8_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
#define TL_iOS9_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 9.0)
#define TL_iOS10_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 10.0)
#define TL_iOS11_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
#define TL_iOS12_VERSTION_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 12.0)

// 销毁打印
#define TLDealloc TLLog(@"\n =========+++ %@  销毁了 +++======== \n",[self class])

// 是否为空对象
#define TLObjectIsNil(__object)  ((nil == __object) || [__object isKindOfClass:[NSNull class]])

// 字符串为空
#define TLStringIsEmpty(__string) ((__string.length == 0) || TLObjectIsNil(__string))

// 字符串不为空
#define TLStringIsNotEmpty(__string)  (!TLStringIsEmpty(__string))

// 数组为空
#define TLArrayIsEmpty(__array) ((TLObjectIsNil(__array)) || (__array.count==0))

// 取消ios7以后下移
#define TLDisabledAutomaticallyAdjustsScrollViewInsets \
if (TLIOSVersion>=7.0) {\
self.automaticallyAdjustsScrollViewInsets = NO;\
}

// AppCaches 文件夹路径
#define TLCachesDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// NSNotificationCenter
#define TLNotificationDefaultCenter [NSNotificationCenter defaultCenter]

// App DocumentDirectory 文件夹路径
#define TLDocumentDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject]

// 系统放大倍数
#define TLScale [[UIScreen mainScreen] scale]

/**
 *  Frame PX  ---> Pt 6的宽度 全部向下取整数
 */
#define TLPxConvertPt(__Px) floor((__Px) * TLMainScreenWidth/375.0f)
/**
 *  Frame PX  ---> Pt 6的宽度 返回一个合适的值 按钮手指触摸点 44
 */
#define TLFxConvertFitPt(__px) (MAX(TLPxConvertPt(__Px),44))


// 设置图片
#define TLImageNamed(__imageName) [UIImage imageNamed:__imageName]


/// 适配iPhone X + iOS 11
#define TLAdjustsScrollViewInsets_Never(__scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([__scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = __scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)

#endif /* TLMarcos_h */
