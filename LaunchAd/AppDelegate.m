//
//  AppDelegate.m
//  LaunchAd
//
//  Created by admin on 2019/11/13.
//  Copyright © 2019 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AFNetworking.h"
#import "SZLaunchAdPage.h"

@interface AppDelegate ()
{
    SZLaunchAdPage *_launchAd;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [self loadLaunchAd];
    
    return YES;
}


- (void)loadLaunchAd {
    _launchAd = [[SZLaunchAdPage alloc] init];
    _launchAd.ADduration = 5;
    _launchAd.timeoutDuration = 3;
    _launchAd.ADImageURL = @"https://c-ssl.duitang.com/uploads/item/201805/11/20180511135645_VHNGu.thumb.700_0.jpeg";
    _launchAd.skipButtonClickBlock = ^{
        NSLog(@"点击了跳过");
    };
    _launchAd.launchAdClosed = ^{
        NSLog(@"广告已关闭");
    };
    _launchAd.launchAdClickBlock = ^{
        NSLog(@"点击了广告");
    };
    _launchAd.launchAdLoadError = ^(NSError * _Nonnull error) {
        NSLog(@"广告加载失败 - %@", error);
    };
    [self.window addSubview:_launchAd.view];
    
}


@end
