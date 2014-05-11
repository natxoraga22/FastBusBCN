//
//  FavoriteBusStopsManager.h
//  FastBusBCN
//
//  Created by Natxo Raga on 10/05/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FavoriteBusStopsManager : NSObject

// Keys used in order to acces the favorite bus stops dictionary
extern NSString *const FAVORITE_BUS_STOPS_KEY;
extern NSString *const FAVORITE_BUS_STOP_ID_KEY;
extern NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY;

#pragma mark - Querying

+ (NSArray *)favoriteBusStops;
+ (NSUInteger)favoriteBusStopsCount;
+ (NSDictionary *)favoriteBusStopAtIndex:(NSUInteger)index;
+ (NSDictionary *)favoriteBusStopWithStopID:(NSUInteger)stopID;
+ (BOOL)busStopWithStopIDisFavorite:(NSUInteger)stopID;

#pragma mark - Adding/Removing

+ (void)addFavoriteBusStopWithID:(NSUInteger)stopID andCustomName:(NSString *)stopCustomName;
+ (void)removeFavoriteBusStopAtIndex:(NSUInteger)index;
+ (void)removeFavoriteBusStopWithID:(NSUInteger)stopID;

#pragma mark - Modifying

+ (void)setCustomName:(NSString *)stopCustomName forFavoriteBusStopAtIndex:(NSUInteger)index;

#pragma mark - Organizing

+ (void)moveFavoriteBusStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
