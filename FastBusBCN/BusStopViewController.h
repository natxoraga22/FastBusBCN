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

/// Bus stop identifier
@property (nonatomic) NSInteger stopID;

@end
