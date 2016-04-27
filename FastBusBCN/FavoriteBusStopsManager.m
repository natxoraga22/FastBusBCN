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

+ (NSArray<NSData*>*)favoriteBusStops
{
    // Update user defaults from FastBus 1.0 to 2.0 if needed
    [self updateFavoriteBusStops];
    
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

+ (NSString*)customNoteForBusLine:(NSString*)lineID andBusStop:(NSUInteger)stopID
{
    BusStop* busStop = [self favoriteBusStopWithID:stopID];
    BusLine* busLine = [busStop busLineWithID:lineID];
    return busLine.customNote;
}

#pragma mark - Adding/Removing

+ (void)addBusStopToFavorites:(BusStop*)busStop
{
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    if (!favoriteBusStops) favoriteBusStops = [[NSMutableArray alloc] init];
    
    NSData* busStopData = [NSKeyedArchiver archivedDataWithRootObject:busStop];
    [favoriteBusStops addObject:busStopData];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)removeFavoriteBusStopAtIndex:(NSUInteger)index
{
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    
    [favoriteBusStops removeObjectAtIndex:index];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)removeFavoriteBusStopWithID:(NSUInteger)stopID
{
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    BusStop* favoriteBusStop = [self favoriteBusStopWithID:stopID];
    NSData* favoriteBusStopData = [NSKeyedArchiver archivedDataWithRootObject:favoriteBusStop];
    
    [favoriteBusStops removeObject:favoriteBusStopData];
    
    [self setFavoriteBusStops:favoriteBusStops];
}


#pragma mark - Modifying

+ (void)setCustomName:(NSString *)customName forFavoriteBusStopAtIndex:(NSUInteger)index
{
    BusStop* favoriteBusStop = [self favoriteBusStopAtIndex:index];
    favoriteBusStop.customName = customName;
    
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    favoriteBusStops[index] = [NSKeyedArchiver archivedDataWithRootObject:favoriteBusStop];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

+ (void)addBusLine:(BusLine*)busLine toBusStopWithID:(NSUInteger)stopID
{
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    BusStop* favoriteBusStop = [self favoriteBusStopWithID:stopID];
    
    // First remove the old bus stop data
    [favoriteBusStops removeObject:[NSKeyedArchiver archivedDataWithRootObject:favoriteBusStop]];
    
    // Add the bus line to the bus stop and add the new data
    [favoriteBusStop addBusLine:busLine];
    [favoriteBusStops addObject:[NSKeyedArchiver archivedDataWithRootObject:favoriteBusStop]];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Organizing

+ (void)moveFavoriteBusStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray<NSData*>* favoriteBusStops = [[self favoriteBusStops] mutableCopy];
    NSData* movingBusStop = favoriteBusStops[fromIndex];
    
    // Remove the bus stop from the old index and insert it to the new index
    [favoriteBusStops removeObjectAtIndex:fromIndex];
    [favoriteBusStops insertObject:movingBusStop atIndex:toIndex];
    
    [self setFavoriteBusStops:favoriteBusStops];
}

#pragma mark - Private utility methods

+ (void)setFavoriteBusStops:(NSArray<NSData*>*)favoriteBusStops
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

// Old keys from the bus stop NSDictionary
static NSString* const FAVORITE_BUS_STOP_ID_KEY = @"FavoriteBusStopID";
static NSString* const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY = @"FavoriteBusStopCustomName";

+ (void)updateFavoriteBusStops
{
    NSMutableArray* favoriteBusStops = [[[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    BOOL somethingUpdated = NO;
    for (int i = 0; i < favoriteBusStops.count; i++) {
        NSObject* favoriteBusStop = favoriteBusStops[i];
        
        // If we find a Bus Stop in NSDictionary form, transform it into an archived BusStop
        if ([favoriteBusStop isKindOfClass:[NSDictionary class]]) {
            somethingUpdated = YES;
            NSDictionary* busStopDictionary = (NSDictionary*)favoriteBusStop;
            NSUInteger busStopID = [[busStopDictionary objectForKey:FAVORITE_BUS_STOP_ID_KEY] unsignedIntegerValue];
            NSString* busStopCustomName = [busStopDictionary objectForKey:FAVORITE_BUS_STOP_CUSTOM_NAME_KEY];
            BusStop *busStop = [[BusStop alloc] initWithID:busStopID andCustomName:busStopCustomName];
            favoriteBusStops[i] = [NSKeyedArchiver archivedDataWithRootObject:busStop];
        }
    }
    if (somethingUpdated) [self setFavoriteBusStops:[favoriteBusStops copy]];
}

@end
