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

@property (strong, nonatomic, readonly) NSDictionary *busStopInfo;
@property (nonatomic, readonly) BOOL busStopFound;
@property (weak, nonatomic) id<NextBusesFetcherDataDelegate> delegate;

- (void)fetchStopNameAndNextBusesForStop:(NSInteger)stopID;

@end
