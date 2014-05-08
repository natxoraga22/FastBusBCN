//
//  NextBusesFetcher.h
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextBusesFetcherDataDelegate.h"


@protocol NextBusesFetcherDataDelegate;


@interface NextBusesFetcher : NSObject <NSURLConnectionDataDelegate>

// Keys used in order to acces the next buses dictionary
extern NSString *const FETCHED_NEXT_BUSES_KEY;
extern NSString *const FETCHED_NEXT_BUS_LINE_KEY;
extern NSString *const FETCHED_NEXT_BUS_TIME_KEY;

/// NSDictionary storing the last fetched bus stop information
@property (strong, nonatomic, readonly) NSDictionary *busStopInfo;

/// True if the last fetched bus stop has been found, false otherwise
@property (nonatomic, readonly) BOOL busStopFound;

/// Data delegate that will be notified when fetching finishes or fails
@property (weak, nonatomic) id<NextBusesFetcherDataDelegate> delegate;

/**
 * Fetch our source in order to obtain the stop name and the next buses for the bus stop
 * with the stop ID given as a parameter.
 * @param stopID The bus stop identifier.
 */
- (void)fetchStopNameAndNextBusesForStop:(NSInteger)stopID;

@end
