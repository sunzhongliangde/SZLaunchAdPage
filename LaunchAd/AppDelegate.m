//
//  AppDelegate.m
//  LaunchAd
//
//  Created by admin on 2019/11/13.
//  Copyright © 2019 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
