//
//  FavoriteBusStopsManager.m
//  FastBusBCN
//
//  Created by Natxo Raga on 10/05/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "FavoriteBusStopsManager.h"


@implementation FavoriteBusStopsManager

static NSString* const FAVORITE_BUS_STOPS_KEY = @"FavoriteBusStops";

#pragma mark - Querying

+ (NSArray*)favoriteBusStops
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
}

+ (NSUInteger)favoriteBusStopsCount
{
    if ([self favoriteBusStops]) return [[self favoriteBusStops] count];
    else return 0;
}

+ (BusStop*)favoriteBusStopAtIndex:(NSUInteger)index
{
    NSData* favoriteBusStopData = [self favoriteBusStops][index];
    BusStop* favoriteBusStop = [NSKeyedUnarchiver unarchiveObjectWithData:favoriteBusStopData];
    return favoriteBusStop;
}

+ (BusStop*)favoriteBusStopWithID:(NSUInteger)stopID
{
    for (NSData* favoriteBusStopData in [self favoriteBusStops]) {
        BusStop* favoriteBusStop = [NSKeyedUnarchiver unarchiveObjectWithData:favoriteBusStopData];
        if (favoriteBusStop.identifier == stopID) return favoriteBusStop;
    }
    return nil;
}

+ (BOOL)busStopWithIDisFavorite:(NSUInteger)stopID
{
    return [self favoriteBusStopWithID:stopID] != nil;
}

#pragma mark - Adding/Removing

+ (void)addBusStopToFavorites:(BusStop*)busStop
{
    NSMutableArray *favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    if (!favoriteBusStops) favoriteBusStops = [[NSMutableArray alloc] init];
    
    NSData* busStopData = [NSKeyedArchiver archivedDataWithRootObject:busStop];
    [favoriteBusStops addObject:busStopData];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)removeFavoriteBusStopAtIndex:(NSUInteger)index
{
    NSMutableArray* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    
    [favoriteBusStops removeObjectAtIndex:index];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Modifying

+ (void)setCustomName:(NSString *)customName forFavoriteBusStopAtIndex:(NSUInteger)index
{
    NSMutableArray* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    NSData* favoriteBusStopData = favoriteBusStops[index];
    BusStop* favoriteBusStop = [NSKeyedUnarchiver unarchiveObjectWithData:favoriteBusStopData];
    
    favoriteBusStop.customName = customName;
    favoriteBusStops[index] = [NSKeyedArchiver archivedDataWithRootObject:favoriteBusStop];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Organizing

+ (void)moveFavoriteBusStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    NSData* movingBusStop = favoriteBusStops[fromIndex];
    
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
