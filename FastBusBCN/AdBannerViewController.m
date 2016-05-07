//
//  AdBannerViewController.m
//  FastBusBCN
//
//  Created by Ignacio Raga Llorens on 7/5/16.
//  Copyright © 2016 RagaSoft. All rights reserved.
//

#import "AdBannerViewController.h"

@import GoogleMobileAds;


@interface AdBannerViewController() <GADBannerViewDelegate>
//@property (weak, nonatomic) IBOutlet GADBannerView* bannerView;
@end


@implementation AdBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGPoint bannerViewOrigin = CGPointMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y + self.view.bounds.size.height);
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait
                                                               origin:bannerViewOrigin];
    [self.view addSubview:bannerView];
    bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    bannerView.rootViewController = self;
    bannerView.delegate = self;
    [bannerView loadRequest:[GADRequest request]];    
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    adView.frame = CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.origin.y + self.view.bounds.size.height,
                              adView.frame.size.width,
                              adView.frame.size.height);
    [UIView animateWithDuration:1.0 animations:^{
        adView.frame = CGRectMake(adView.frame.origin.x,
                                  adView.frame.origin.y - adView.frame.size.height,
                                  adView.frame.size.width,
                                  adView.frame.size.height);
    }];
}

@end
