//
//  BusStopViewController.h
//  FastBusBCN
//
//  Created by Natxo Raga on 19/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "NextBusesFetcherDataDelegate.h"


@interface BusStopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NextBusesFetcherDataDelegate, UIAlertViewDelegate>

// Keys used in order to acces the favorite bus stops dictionary
extern NSString *const FAVORITE_BUS_STOPS_KEY;
extern NSString *const FAVORITE_BUS_STOP_ID_KEY;
extern NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY;

@property (nonatomic) NSInteger stopID;

@end
