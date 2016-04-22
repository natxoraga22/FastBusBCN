//
//  FavoriteBusStopsManager.h
//  FastBusBCN
//
//  Created by Natxo Raga on 10/05/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"


@interface FavoriteBusStopsManager : NSObject

#pragma mark - Querying

+ (NSUInteger)favoriteBusStopsCount;
+ (BusStop*)favoriteBusStopAtIndex:(NSUInteger)index;
+ (BusStop*)favoriteBusStopWithID:(NSUInteger)stopID;
+ (BOOL)busStopWithIDisFavorite:(NSUInteger)stopID;

#pragma mark - Adding/Removing

+ (void)addBusStopToFavorites:(BusStop*)busStop;
+ (void)removeFavoriteBusStopAtIndex:(NSUInteger)index;

#pragma mark - Modifying

+ (void)setCustomName:(NSString *)stopCustomName forFavoriteBusStopAtIndex:(NSUInteger)index;

#pragma mark - Organizing

+ (void)moveFavoriteBusStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
