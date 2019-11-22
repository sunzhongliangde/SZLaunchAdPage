# SZLaunchAdPage
一款简单易用的iOS启动页广告

## Overview
<img src="https://github.com/sunzhongliangde/SZLaunchAdPage/blob/master/effects.gif" referrerpolicy="no-referrer">

How to use
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
