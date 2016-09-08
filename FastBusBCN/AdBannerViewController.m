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
@property (strong, nonatomic) IBOutlet GADBannerView* bannerView;
@end


@implementation AdBannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint bannerViewOrigin = CGPointMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y + self.view.bounds.size.height);
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait
                                                 origin:bannerViewOrigin];
    [self.view addSubview:self.bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat yOrigin = 0.0;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
        yOrigin = self.view.bounds.origin.y + self.view.bounds.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height;
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
        yOrigin = self.view.bounds.origin.y + self.view.bounds.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height;
    }
    self.bannerView.frame = CGRectMake(self.bannerView.frame.origin.x,
                                       yOrigin,
                                       self.bannerView.frame.size.width,
                                       self.bannerView.frame.size.height);
    // TODO Mirar si fent adSize = elquesigui es crida a adViewDidreceiveAd, ja que si es aixi no fa falta canviarli el frame aqui crec
    // Fer PROVES
    // Tambe mirar que el primer adSize que s'aplica sigui depenent de la orientacio, ja que ara
    // si clico a una parada en landscape quan apareix el busstopviewcontroller peta
}

@end
