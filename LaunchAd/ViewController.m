//
//  ViewController.m
//  LaunchAd
//
//  Created by admin on 2019/11/13.
//  Copyright © 2019 admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *text = [[UILabel alloc] init];
    text.frame = CGRectMake(100, 100, 190, 100);
    text.text = @"这是主界面";
    [self.view addSubview:text];
}


@end
