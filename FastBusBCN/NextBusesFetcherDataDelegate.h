//
//  NextBusesFetcherDataDelegate.h
//  FastBusBCN
//
//  Created by Natxo Raga on 17/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextBusesFetcher.h"


@class NextBusesFetcher;


@protocol NextBusesFetcherDataDelegate <NSObject>

- (void)nextBusesFetcherDidFinishLoading:(NextBusesFetcher *)nextBusesFetcher;

@end
