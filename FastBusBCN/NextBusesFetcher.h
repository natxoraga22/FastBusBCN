//
//  NextBusesFetcher.h
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextBusesFetcherDataDelegate.h"
#import "BusLine.h"


@protocol NextBusesFetcherDataDelegate;


@interface NextBusesFetcher : NSObject <NSURLConnectionDataDelegate>

/// NSArray storing the next buses info
@property (strong, nonatomic, readonly) NSArray<BusLine*>* nextBuses;

/// True if the last fetched bus stop has been found, false otherwise
@property (nonatomic, readonly) BOOL busStopFound;

/// Data delegate that will be notified when fetching finishes or fails
@property (weak, nonatomic) id<NextBusesFetcherDataDelegate> delegate;

/**
 * Fetch our source in order to obtain the next buses that will arrive at the bus stop with the stop ID given as a parameter.
 * @param stopID The bus stop identifier.
 */
- (void)fetchNextBusesForStop:(NSInteger)stopID;

@end
