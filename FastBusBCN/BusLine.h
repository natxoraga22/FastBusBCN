//
//  BusLine.h
//  FastBusBCN
//
//  Created by Ignacio Raga Llorens on 22/4/16.
//  Copyright © 2016 RagaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BusLine : NSObject <NSCoding>

@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSArray<NSNumber*>* remainingTimes;  // NSArray of NSUInteger representing time in minutes
@property (strong, nonatomic) NSString* customNote;

@end
