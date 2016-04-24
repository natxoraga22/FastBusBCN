//
//  BusLine.m
//  FastBusBCN
//
//  Created by Ignacio Raga Llorens on 22/4/16.
//  Copyright © 2016 RagaSoft. All rights reserved.
//

#import "BusLine.h"


@implementation BusLine

- (instancetype)initWithID:(NSString*)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

- (NSArray<NSNumber*>*)remainingTimes
{
    if (!_remainingTimes) {
        _remainingTimes = [[NSArray<NSNumber*> alloc] init];
    }
    return _remainingTimes;
}

- (void)addRemainingTime:(NSUInteger)remainingTime
{
    self.remainingTimes = [self.remainingTimes arrayByAddingObject:@(remainingTime)];
}

#pragma mark - NSCoding

static NSString* const IDENTIFIER_KEY = @"identifier";
static NSString* const REMAINING_TIMES_KEY = @"remainingTimes";
static NSString* const CUSTOM_NOTE_KEY = @"customNote";

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.identifier forKey:IDENTIFIER_KEY];
    [encoder encodeObject:self.remainingTimes forKey:REMAINING_TIMES_KEY];
    [encoder encodeObject:self.customNote forKey:CUSTOM_NOTE_KEY];
}

- (id)initWithCoder:(NSCoder*)decoder {
    self.identifier = [decoder decodeObjectForKey:IDENTIFIER_KEY];
    self.remainingTimes = [decoder decodeObjectForKey:REMAINING_TIMES_KEY];
    self.customNote = [decoder decodeObjectForKey:CUSTOM_NOTE_KEY];
    return self;
}

@end
