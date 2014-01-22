//
//  NextBusesFetcher.m
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "NextBusesFetcher.h"
#import "HTMLReader.h"


@interface NextBusesFetcher()
@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *nextBusesHTMLData;
@property (strong, nonatomic, readwrite) NSDictionary *busStopInfo;
@end


@implementation NextBusesFetcher

// Keys used in order to acces the next buses dictionary
NSString *const FETCHED_BUS_STOP_NAME_KEY = @"FetchedBusStopName";
NSString *const FETCHED_NEXT_BUSES_KEY = @"FetchedNextBuses";
NSString *const FETCHED_NEXT_BUS_LINE_KEY = @"FetchedNextBus_BusLine";
NSString *const FETCHED_NEXT_BUS_TIME_KEY = @"FetchedNextBus_BusTime";

#pragma mark - Fetching

static NSString *const NEXT_BUSES_URL = @"http://www.ambmobilitat.cat/ambtempsbus?codi=";

- (void)fetchStopNameAndNextBusesForStop:(NSInteger)stopID
{    
    // Create the HTML call string
    NSString *nextBusesFetchingString = [NSString stringWithFormat:@"%@%d", NEXT_BUSES_URL, stopID];

    // Create the URL to make the call
    NSURL *nextBusesFetchingURL = [NSURL URLWithString:nextBusesFetchingString];
    NSURLRequest *nextBusesURLRequest = [NSURLRequest requestWithURL:nextBusesFetchingURL];
    
    // Cancel any current connections
    if (self.currentConnection)
    {
        [self.currentConnection cancel];
        self.currentConnection = nil;
        self.nextBusesHTMLData = nil;
    }
    
    // Connection itself
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:nextBusesURLRequest delegate:self];
    
    // If the connection was successful, create the data that will be returned
    self.nextBusesHTMLData = [NSMutableData data];
}

#pragma mark - Parsing

static NSString *const BUS_STOP_NAME_CSS_SELECTOR = @"li[data-role='list-divider'] div span:nth-child(3)";
static NSString *const NEXT_BUSES_CSS_SELECTOR = @"div[id^=linia]";
static NSString *const NEXT_BUS_TIME_CSS_SELECTOR = @"div:nth-child(2) b span";

- (void)parseObtainedHTMLData
{
    NSString *nextBusesHTMLString = [[NSString alloc] initWithData:self.nextBusesHTMLData encoding:NSUTF8StringEncoding];
    
    // Create the HTML parser
    HTMLDocument *HTMLParser = [HTMLDocument documentWithString:nextBusesHTMLString];

    // Parse the HTML in order to obtain the stop name
    NSMutableDictionary *busStopMutableInfo = [[NSMutableDictionary alloc] init];
    HTMLNode *busStopNameNode = [HTMLParser firstNodeMatchingSelector:BUS_STOP_NAME_CSS_SELECTOR];
    [busStopMutableInfo setObject:[busStopNameNode innerHTML] forKey:FETCHED_BUS_STOP_NAME_KEY];
    
    // Parse the HTML in order to obtain the next buses
    NSArray *nextBusesNodes = [HTMLParser nodesMatchingSelector:NEXT_BUSES_CSS_SELECTOR];
    NSMutableArray *nextBuses = [[NSMutableArray alloc] init];
    for (HTMLNode *nextBusNode in nextBusesNodes) {
        NSString *busLine = [nextBusNode innerHTML];
        HTMLElementNode *busTimeElement = (HTMLElementNode *)[nextBusNode.parentNode firstNodeMatchingSelector:NEXT_BUS_TIME_CSS_SELECTOR];
        NSInteger busTime = [self parseTime:[busTimeElement innerHTML]];
        
        BOOL found = NO;
        for (int i = 0; i < [nextBuses count]; i++) {
            NSDictionary *nextBus = [nextBuses objectAtIndex:i];
            // If we already have the line, add the time
            if ([[nextBus objectForKey:FETCHED_NEXT_BUS_LINE_KEY] isEqualToString:busLine]) {
                found = YES;
                NSMutableDictionary *mutableNextBus = [nextBus mutableCopy];
                NSArray *nextBusTime = [[mutableNextBus objectForKey:FETCHED_NEXT_BUS_TIME_KEY] arrayByAddingObject:@(busTime)];
                [mutableNextBus setObject:nextBusTime forKey:FETCHED_NEXT_BUS_TIME_KEY];
                [nextBuses replaceObjectAtIndex:i withObject:[mutableNextBus copy]];
            }
        }
        // Otherwise, create a new line with the corresponding time
        if (!found) {
            [nextBuses addObject:@{FETCHED_NEXT_BUS_LINE_KEY: busLine,
                                   FETCHED_NEXT_BUS_TIME_KEY: @[@(busTime)]}];
        }
    }
    [busStopMutableInfo setObject:[nextBuses copy] forKey:FETCHED_NEXT_BUSES_KEY];
    
    self.busStopInfo = [busStopMutableInfo copy];
}

- (NSInteger)parseTime:(NSString *)time
{
    NSString *timeParsed = time;
    NSRange range = [time rangeOfString:@" "];
    if (range.location != NSNotFound) timeParsed = [time substringToIndex:range.location];
    return [timeParsed integerValue];
}

#pragma mark - NSURLConnection Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Reset the data
    [self.nextBusesHTMLData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the data (this method will probably be called several times)
    [self.nextBusesHTMLData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NextBusesFetcher - URL Connection Failed");
    self.currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"NextBusesFetcher - URL Connection Finished");
    self.currentConnection = nil;
    
    // Parse the data
    [self parseObtainedHTMLData];
    
    // Notify our delegate
    [self.delegate nextBusesFetcherDidFinishLoading:self];
}

@end
