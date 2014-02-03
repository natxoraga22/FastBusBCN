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
@property (nonatomic, readwrite) BOOL busStopFound;
@end


@implementation NextBusesFetcher

// Keys used in order to acces the next buses dictionary
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

static NSString *const NEXT_BUSES_CSS_SELECTOR = @"ul[data-role='listview'] li";
static NSString *const NEXT_BUS_LINE_CSS_SELECTOR = @"div b";
static NSString *const NEXT_BUS_TIME_CSS_SELECTOR = @"div b span";

- (void)parseObtainedHTMLData
{
    NSString *nextBusesHTMLString = [[NSString alloc] initWithData:self.nextBusesHTMLData encoding:NSUTF8StringEncoding];
    
    // Create the HTML parser
    HTMLDocument *HTMLParser = [HTMLDocument documentWithString:nextBusesHTMLString];
    NSMutableDictionary *busStopMutableInfo = [[NSMutableDictionary alloc] init];
    
    // Parse the HTML in order to obtain the next buses
    NSMutableArray *nextBusesNodes = [[HTMLParser nodesMatchingSelector:NEXT_BUSES_CSS_SELECTOR] mutableCopy];
    [nextBusesNodes removeObjectAtIndex:0];
    
    // We have to make sure the stop is valid
    if ([[[nextBusesNodes firstObject] innerHTML] rangeOfString:@"Línia" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        self.busStopFound = NO;
    }
    else self.busStopFound = YES;
    
    // If the stop is valid, parse the data
    if (self.busStopFound) {
        NSMutableArray *nextBuses = [[NSMutableArray alloc] init];
        for (HTMLNode *nextBusNode in nextBusesNodes) {
            // BUS LINE
            NSString *busLine = [self parseLine:[[nextBusNode firstNodeMatchingSelector:NEXT_BUS_LINE_CSS_SELECTOR] innerHTML]];
            // BUS TIME
            NSUInteger busTime = [self parseTime:[[nextBusNode firstNodeMatchingSelector:NEXT_BUS_TIME_CSS_SELECTOR] innerHTML]];
            
            BOOL found = NO;
            for (int i = 0; i < [nextBuses count]; i++) {
                NSDictionary *nextBus = nextBuses[i];
                // If we already have the line, add the time
                if ([nextBus[FETCHED_NEXT_BUS_LINE_KEY] isEqualToString:busLine]) {
                    found = YES;
                    NSMutableDictionary *mutableNextBus = [nextBus mutableCopy];
                    NSArray *nextBusTime = [mutableNextBus[FETCHED_NEXT_BUS_TIME_KEY] arrayByAddingObject:@(busTime)];
                    mutableNextBus[FETCHED_NEXT_BUS_TIME_KEY] = nextBusTime;
                    nextBuses[i] = [mutableNextBus copy];
                }
            }
            // Otherwise, create a new line with the corresponding time
            if (!found) {
                [nextBuses addObject:@{FETCHED_NEXT_BUS_LINE_KEY: busLine,
                                       FETCHED_NEXT_BUS_TIME_KEY: @[@(busTime)]}];
            }
        }
        busStopMutableInfo[FETCHED_NEXT_BUSES_KEY] = [nextBuses copy];

        self.busStopInfo = [busStopMutableInfo copy];
    }
    else self.busStopInfo = nil;
}

- (NSString *)parseLine:(NSString *)line
{
    return [line componentsSeparatedByString:@" "][1];
}

- (NSUInteger)parseTime:(NSString *)time
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
