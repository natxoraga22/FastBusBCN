//
//  FavoriteBusStopsManager.m
//  FastBusBCN
//
//  Created by Natxo Raga on 10/05/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "FavoriteBusStopsManager.h"


@implementation FavoriteBusStopsManager

// Keys used in order to acces the favorite bus stop dictionary
NSString *const FAVORITE_BUS_STOPS_KEY = @"FavoriteBusStops";
NSString *const FAVORITE_BUS_STOP_ID_KEY = @"FavoriteBusStopID";
NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY = @"FavoriteBusStopCustomName";

#pragma mark - Querying

+ (NSArray *)favoriteBusStops
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
}

+ (NSUInteger)favoriteBusStopsCount
{
    if ([self favoriteBusStops]) return [[self favoriteBusStops] count];
    else return 0;
}

+ (NSDictionary *)favoriteBusStopAtIndex:(NSUInteger)index
{
    return [self favoriteBusStops][index];
}

+ (NSDictionary *)favoriteBusStopWithStopID:(NSUInteger)stopID
{
    for (NSDictionary *favoriteBusStop in [self favoriteBusStops]) {
        if ([favoriteBusStop[FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(stopID)]) {
            return favoriteBusStop;
        }
    }
    return nil;
}

+ (BOOL)busStopWithStopIDisFavorite:(NSUInteger)stopID
{
    return [self favoriteBusStopWithStopID:stopID] != nil;
}

#pragma mark - Adding/Removing

+ (void)addFavoriteBusStopWithID:(NSUInteger)stopID andCustomName:(NSString *)stopCustomName
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    if (!favoriteBusStops) favoriteBusStops = [[NSMutableArray alloc] init];
    
    [favoriteBusStops addObject:@{FAVORITE_BUS_STOP_ID_KEY: @(stopID),
                                  FAVORITE_BUS_STOP_CUSTOM_NAME_KEY: stopCustomName}];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)removeFavoriteBusStopAtIndex:(NSUInteger)index
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    
    [favoriteBusStops removeObjectAtIndex:index];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)removeFavoriteBusStopWithID:(NSUInteger)stopID
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    
    [favoriteBusStops removeObject:[self favoriteBusStopWithStopID:stopID]];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Modifying

+ (void)setCustomName:(NSString *)stopCustomName forFavoriteBusStopAtIndex:(NSUInteger)index
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    NSMutableDictionary *favoriteBusStop = [favoriteBusStops[index] mutableCopy];
    
    favoriteBusStop[FAVORITE_BUS_STOP_CUSTOM_NAME_KEY] = stopCustomName;
    favoriteBusStops[index] = favoriteBusStop;
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Organizing

+ (void)moveFavoriteBusStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    NSDictionary *movingBusStop = favoriteBusStops[fromIndex];
    
    // Remove the bus stop from the old index and insert it to the new index
    [favoriteBusStops removeObjectAtIndex:fromIndex];
    [favoriteBusStops insertObject:movingBusStop atIndex:toIndex];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Private utility methods

+ (void)setFavoriteBusStops:(NSArray *)favoriteBusStops
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

@end
