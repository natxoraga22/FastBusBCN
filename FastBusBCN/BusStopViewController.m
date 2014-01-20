//
//  BusStopViewController.m
//  FastBusBCN
//
//  Created by Natxo Raga on 19/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "BusStopViewController.h"
#import "NextBusTableViewCell.h"
#import "NextBusesFetcher.h"


@interface BusStopViewController ()
@property (weak, nonatomic) IBOutlet UITableView *nextBusesTableView;
@property (weak, nonatomic) IBOutlet UILabel *busStopNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) NextBusesFetcher *nextBusesFetcher;
@end


@implementation BusStopViewController

// Keys used in order to acces the favorite bus stop dictionary
NSString *const FAVORITE_BUS_STOPS_KEY = @"FavoriteBusStops";
NSString *const FAVORITE_BUS_STOP_ID_KEY = @"FavoriteBusStopID";
NSString *const FAVORITE_BUS_STOP_NAME_KEY = @"FavoriteBusStopName";
NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY = @"FavoriteBusStopCustomName";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Parada %d", self.stopID];
    //self.favoriteButton.ima
    
    self.nextBusesFetcher = [[NextBusesFetcher alloc] init];
    self.nextBusesFetcher.delegate = self;
    [self fetchNextBuses];
}

- (void)fetchNextBuses
{
    [self.nextBusesFetcher fetchStopNameAndNextBusesForStop:self.stopID];
    //self.navigationItem.rightBarButtonItem = [[UIActivityIndicatorView alloc] init];
}
    
#pragma mark - NextBusesFetcher Data Delegate

- (void)nextBusesFetcherDidFinishLoading:(NextBusesFetcher *)nextBusesFetcher
{
    self.busStopNameLabel.text = [[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_BUS_STOP_NAME_KEY];
    [self.nextBusesTableView reloadData];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *nextBuses = [[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_NEXT_BUSES_KEY];
    if (nextBuses == nil) return 0;
    return [nextBuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NextBusInfo";
    NextBusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *nextBus = [[[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_NEXT_BUSES_KEY] objectAtIndex:indexPath.row];
    cell.nextBusLineLabel.text = [nextBus objectForKey:FETCHED_NEXT_BUS_LINE_KEY];
    cell.nextBusTimeLabel.text = [NSString stringWithFormat:@"%@", [nextBus objectForKey:FETCHED_NEXT_BUS_TIME_KEY]];

    return cell;
}

@end
