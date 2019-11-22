//
//  SZLaunchAdPage.h
//  LaunchAd
//
//  Created by admin on 2019/11/14.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZLaunchAdPage : UIViewController

/**
 广告持续显示时间（默认3秒钟）
 */
@property (nonatomic, assign) NSInteger ADduration;

/**
 广告加载超时时间（默认3秒钟）
 */
@property (nonatomic, assign) NSInteger timeoutDuration;

/**
 广告图片URL
 */
@property (nonatomic, copy) NSString *ADImageURL;

/**
 是否隐藏跳过按钮
 */
@property (nonatomic, assign) BOOL hideSkipButton;

/**
 广告点击事件回调
 */
@property (nonatomic, copy) void(^launchAdClickBlock)(void);

/**
 跳过按钮点击事件回调
 */
@property (nonatomic, copy) void(^skipButtonClickBlock)(void);

/**
 广告关闭回调
 */
@property (nonatomic, copy) void(^launchAdClosed)(void);

/// 广告加载失败
@property (nonatomic, copy) void(^launchAdLoadError)(NSError *error);


@end

NS_ASSUME_NONNULL_END
