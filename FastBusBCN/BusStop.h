//
//  BusStop.h
//  FastBusBCN
//
//  Created by Ignacio Raga Llorens on 22/4/16.
//  Copyright © 2016 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusLine.h"


@interface BusStop : NSObject <NSCoding>

@property (nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString* customName;
@property (strong, nonatomic) NSArray<BusLine*>* busLines;

- (instancetype)initWithID:(NSUInteger)identifier andCustomName:(NSString*)customName;

- (BusLine*)busLineWithID:(NSString*)lineID;
- (void)addBusLine:(BusLine*)busLine;

@end
