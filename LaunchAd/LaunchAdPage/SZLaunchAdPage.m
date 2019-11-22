//
//  SZLaunchAdPage.m
//  LaunchAd
//
//  Created by admin on 2019/11/14.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SZLaunchAdPage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/NSData+ImageContentType.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import "AFNetworking.h"

@interface SZLaunchAdPage ()
@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) UIImageView *ADImageView;  // 启动图片
@property (nonatomic, strong) UIButton *skipButton;      // 跳过按钮
@property (nonatomic, strong) dispatch_source_t timer;   // 设置定时器
@end

// pix转化为point
#define PixToPoint(pixValue) ceil((pixValue) / 3.0 * (UIScreen.mainScreen.bounds.size.width / 414.0f))

@implementation SZLaunchAdPage

- (instancetype)init {
    if (self = [super init]) {
        self.ADduration = 3;
        self.timeoutDuration = 3;
        self.hideSkipButton = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.ADImageView];
    [self.view addSubview:self.skipButton];

    [self.view.layer insertSublayer:self.backgroundLayer atIndex:0];
}

- (void)setADImageURL:(NSString *)ADImageURL {
    _ADImageURL = ADImageURL;
    [self downloadImage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.launchAdClickBlock) {
        self.launchAdClickBlock();
    }
    [self removeLaunchAdPageHUD];
}

#pragma mark - 设置广告图片
- (UIImageView *)ADImageView {
    if (!_ADImageView) {
        _ADImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _ADImageView.userInteractionEnabled = YES;
        _ADImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _ADImageView;
}

- (void)downloadImage {
    // 本地图片
    NSURL *URL = [NSURL URLWithString:self.ADImageURL];
    if ([[URL.scheme lowercaseString] isEqualToString:@"file"]) {
        NSData *localData = [NSData dataWithContentsOfURL:URL];
        if ([NSData sd_imageFormatForImageData:localData] == SDImageFormatGIF) {
            UIImage *gifImage = [UIImage sd_imageWithGIFData:localData];
            self.ADImageView.image = gifImage;
        }
        else {
            [self.ADImageView setImage:[UIImage sd_imageWithData:localData]];
        }
        // 开启倒计时
        [self dispath_timer];
    }
    else {
        __weak typeof(self) weakSelf = self;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = self.timeoutDuration;
        configuration.HTTPShouldSetCookies = NO;
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
        sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
        [sessionManager GET:self.ADImageURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            __strong SZLaunchAdPage *strongSelf = weakSelf;
            UIImage *image = (UIImage *)responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.backgroundLayer removeFromSuperlayer];
                strongSelf.backgroundLayer = nil;
                strongSelf.ADImageView.image = image;
                [strongSelf dispath_timer];
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            __strong SZLaunchAdPage *strongSelf = weakSelf;
            if (strongSelf.launchAdLoadError) {
                strongSelf.launchAdLoadError(error);
            }
            [strongSelf removeLaunchAdPageHUD];
        }];
    }
}

#pragma mark - 设置跳过按钮
- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([self isIPhoneXSeries]) {
            [_skipButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-PixToPoint(42)-PixToPoint(210), PixToPoint(132)+24, PixToPoint(210), PixToPoint(90))];
        }
        else {
            [_skipButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-PixToPoint(42)-PixToPoint(210), PixToPoint(132), PixToPoint(210), PixToPoint(90))];
        }
        
        [_skipButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [_skipButton.layer setCornerRadius:PixToPoint(45)];
        [_skipButton.layer setMasksToBounds:YES];
        [_skipButton setHidden:self.hideSkipButton];
        [self.skipButton setTitle:[NSString stringWithFormat:@"%lds 跳过", (long)self.ADduration] forState:UIControlStateNormal];
        [_skipButton.titleLabel setFont:[UIFont systemFontOfSize:PixToPoint(38)]];
        [_skipButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (void)skipButtonClick {
    [self removeLaunchAdPageHUD];
    if (self.skipButtonClickBlock) {
        self.skipButtonClickBlock();
    }
}

- (void)removeLaunchAdPageHUD {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.launchAdClosed) {
            self.launchAdClosed();
        }
    }];
}

- (void)dispath_timer {
    self.skipButton.hidden = NO;
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), period*NSEC_PER_SEC, 0);
    
    __block NSInteger duration = 3.0;
    if (self.ADduration) {
        duration = self.ADduration;
    }
    
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            duration--;
            if (duration > -1) {
                [self.skipButton setTitle:[NSString stringWithFormat:@"%lds 跳过", (long)(duration+1)]
                                 forState:UIControlStateNormal];
            } else {
                dispatch_source_cancel(self.timer);
                [self removeLaunchAdPageHUD];
            }
        });
    });
    dispatch_resume(self.timer);
}

- (CALayer *)backgroundLayer {
    if (!_backgroundLayer) {
        UIView *launchView = [self getLaunchView];
        if (launchView) {
            return launchView.layer;
        }
        else {
            _backgroundLayer = [[CALayer alloc] init];
            UIImage *image = [self getLaunchImage];
            _backgroundLayer.contents = (__bridge id)image.CGImage;
        }
    }
    return _backgroundLayer;
}

#pragma mark - 获取系统LaunchImage图片

- (UIView *)getLaunchView {
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *storyboardName = [infoPlist objectForKey:@"UILaunchStoryboardName"];
    if (storyboardName.length > 0) {
        UIViewController *viewController = [UIStoryboard storyboardWithName:storyboardName bundle:nil].instantiateInitialViewController;
        return viewController.view;
    }
    
    return nil;
}

- (UIImage *)getLaunchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    NSString *viewOrientation = nil;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
        viewOrientation = @"Portrait";
    } else {
        viewOrientation = @"Landscape";
    }
    
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
            break;
        }
    }
    return [UIImage imageNamed:launchImage];
}

- (BOOL)isIPhoneXSeries {
    static BOOL iphoneX = NO;
    
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (@available(iOS 11.0, *)) {
            if ([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0) {
                iphoneX = YES;
            }
        }
    });
    
    return iphoneX;
}


@end
