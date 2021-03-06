//
//  BusStop.m
//  FastBusBCN
//
//  Created by Ignacio Raga Llorens on 22/4/16.
//  Copyright © 2016 RagaSoft. All rights reserved.
//

#import "BusStop.h"


@implementation BusStop

- (instancetype)initWithID:(NSUInteger)identifier andCustomName:(NSString*)customName
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.customName = customName;
    }
    return self;
}

- (NSArray<BusLine*>*)busLines
{
    if (!_busLines) {
        _busLines = [[NSArray<BusLine*> alloc] init];
    }
    return _busLines;
}

- (BusLine*)busLineWithID:(NSString*)lineID
{
    for (BusLine* busLine in self.busLines) {
        if ([busLine.identifier isEqualToString:lineID]) return busLine;
    }
    return nil;
}

- (void)addBusLine:(BusLine*)newBusLine
{
    NSMutableArray<BusLine*>* mutableBusLines = [self.busLines mutableCopy];
    BOOL found = NO;
    for (int i = 0; i < self.busLines.count; i++) {
        BusLine* busLine = self.busLines[i];
        if ([busLine.identifier isEqualToString:newBusLine.identifier]) {
            found = YES;
            mutableBusLines[i] = newBusLine;
        }
    }
    if (!found) [mutableBusLines addObject:newBusLine];
    self.busLines = [mutableBusLines copy];
}

#pragma mark - NSCoding

static NSString* const IDENTIFIER_KEY = @"identifier";
static NSString* const CUSTOM_NAME_KEY = @"customName";
static NSString* const BUS_LINES_KEY = @"busLines";

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:@(self.identifier) forKey:IDENTIFIER_KEY];
    [encoder encodeObject:self.customName forKey:CUSTOM_NAME_KEY];
    [encoder encodeObject:self.busLines forKey:BUS_LINES_KEY];
}

- (id)initWithCoder:(NSCoder*)decoder {
    self.identifier = [[decoder decodeObjectForKey:IDENTIFIER_KEY] unsignedIntegerValue];
    self.customName = [decoder decodeObjectForKey:CUSTOM_NAME_KEY];
    self.busLines = [decoder decodeObjectForKey:BUS_LINES_KEY];
    return self;
}

@end
