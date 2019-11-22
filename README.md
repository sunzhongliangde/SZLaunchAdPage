# SZLaunchAdPage
一款简单易用的iOS启动页广告

-   支持预加载图片
-   支持作为UIWindow根视图使用
-   支持在UIWindow上添加使用

## Overview
<img src="https://github.com/sunzhongliangde/SZLaunchAdPage/blob/master/effects.gif" referrerpolicy="no-referrer">

#### 支持预加载
可以把广告信息缓存在本地，同时把图片缓存到本地，下次启动时直接使用图片缓存，省去加载图片的时间，使APP启动广告展示更快
```objc
SZLaunchAdPage *launchAd = [[SZLaunchAdPage alloc] init];
launchAd.ADImageURL = @"https://c-ssl.duitang.com/uploads/item/201805/11/20180511135645_VHNGu.thumb.700_0.jpeg";
```

#### 直接展示在UIWindow上面
```objc
_launchAd = [[SZLaunchAdPage alloc] init];
_launchAd.ADduration = 5;
_launchAd.timeoutDuration = 3;
_launchAd.ADImageURL = @"https://c-ssl.duitang.com/uploads/item/201805/11/20180511135645_VHNGu.thumb.700_0.jpeg";
_launchAd.skipButtonClickBlock = ^{
    NSLog(@"点击了跳过");
};
_launchAd.skipButtonClickBlock = ^{
    NSLog(@"点击了广告位");
};
_launchAd.launchAdClickBlock = ^{
    NSLog(@"点击了广告");
};
[self.window addSubview:_launchAd.view];
```

#### 作为根视图使用
```objc
_launchAd = [[SZLaunchAdPage alloc] init];
_launchAd.ADduration = 5;
_launchAd.timeoutDuration = 3;
_launchAd.ADImageURL = @"https://c-ssl.duitang.com/uploads/item/201805/11/20180511135645_VHNGu.thumb.700_0.jpeg";
_launchAd.skipButtonClickBlock = ^{
    NSLog(@"点击了跳过");
};
_launchAd.skipButtonClickBlock = ^{
    NSLog(@"点击了广告位");
};
_launchAd.launchAdClickBlock = ^{
    NSLog(@"点击了广告");
};
self.window.rootViewController = _launchAd;
```
