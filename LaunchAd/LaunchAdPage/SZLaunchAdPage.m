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
#import <SDWebImage/UIImage+MultiFormat.h>

@interface SZLaunchAdPage ()
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
        self.hideSkipButton = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.ADImageView];
    [self.view addSubview:self.skipButton];
}

- (void)setADImageURL:(NSURL *)ADImageURL {
    _ADImageURL = ADImageURL;
    [self downloadImage];
}

#pragma mark - 设置广告图片
- (UIImageView *)ADImageView {
    if (!_ADImageView) {
        _ADImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _ADImageView.image = [self launchImage]; // 初始化设置为launch image
        _ADImageView.userInteractionEnabled = YES;
        _ADImageView.alpha = 1;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adImageViewTapAction:)];
        [self.ADImageView addGestureRecognizer:tap];
    }
    return _ADImageView;
}

- (void)downloadImage {
    if ([[self.ADImageURL.scheme lowercaseString] isEqualToString:@"file"]) {
        NSData *localData = [NSData dataWithContentsOfURL:self.ADImageURL];
        // 本地图片
        if ([[[self.ADImageURL lastPathComponent] lowercaseString] isEqualToString:@"gif"]) {
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
        [self.ADImageView sd_setImageWithURL:self.ADImageURL placeholderImage:[self launchImage] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                [weakSelf removeLaunchAdPageHUD];
                #if DEBUG
                                NSLog(@"------------启动页广告图片下载失败，图片URL%@------%@",imageURL, error);
                #endif
                return;
            }
            // 开启倒计时
            [weakSelf dispath_timer];
        }];
    }
}
            

- (void)adImageViewTapAction:(UITapGestureRecognizer *)tap {
    if (self.launchAdClickBlock) {
        self.launchAdClickBlock();
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
        [_skipButton setTitleColor:[UIColor colorWithRed:143.0/255 green:58.0/255 blue:132.0/255 alpha:1]
                          forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (void)skipButtonClick {
    [self removeLaunchAdPageHUD];
}

- (void)removeLaunchAdPageHUD {
    [UIView animateWithDuration:0.2 animations:^{
        //[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        //self.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.skipButtonClickBlock) {
            self.skipButtonClickBlock();
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

#pragma mark - 获取系统LaunchImage图片
- (UIImage *)launchImage {
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
