//
//  FavouriteBusStopsViewController.m
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "FavoriteBusStopsTableViewController.h"
#import "BusStopViewController.h"


@implementation FavoriteBusStopsTableViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reload the data every time we are going to appear on screen
    // because our data can be modified by other view controllers
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *favoriteBusStops = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
    if (favoriteBusStops == nil) return 0;
    else return [favoriteBusStops count];
}

static NSString *const FAVORITE_BUS_STOP_CELL_ID = @"FavoriteBusStop";
static NSString *const BUS_STOP_STRING = @"Parada";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FAVORITE_BUS_STOP_CELL_ID forIndexPath:indexPath];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *favoriteBusStop = [userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY][indexPath.row];
    
    // Title --> Name, Subtitle --> ID
    cell.textLabel.text = favoriteBusStop[FAVORITE_BUS_STOP_CUSTOM_NAME_KEY];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", BUS_STOP_STRING, favoriteBusStop[FAVORITE_BUS_STOP_ID_KEY]];
    
    return cell;
}

// Rearranging the UITableView
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    NSDictionary *movingBusStop = favoriteBusStops[fromIndexPath.row];
    
    // Remove the bus stop from the old index and insert it to the new index
    [favoriteBusStops removeObjectAtIndex:fromIndexPath.row];
    [favoriteBusStops insertObject:movingBusStop atIndex:toIndexPath.row];
    
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

// Deleting rows from the UITableView
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
        [favoriteBusStops removeObjectAtIndex:indexPath.row];
        [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
        [userDefaults synchronize];
        
        // UI deleting
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

static NSString *const SHOW_NEXT_BUSES_SEGUE_ID = @"ShowNextBuses";
static NSString *const SHOW_SEARCH_BUS_STOP_SEGUE_ID = @"ShowSearchBusStop";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Segue from a UITableView row
    if ([segue.identifier isEqualToString:SHOW_NEXT_BUSES_SEGUE_ID]) {
        BusStopViewController *busStopVC = [segue destinationViewController];
        NSIndexPath *busStopIndexPath = [self.tableView indexPathForSelectedRow];
        NSArray *favoriteBusStops = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
        busStopVC.stopID = [favoriteBusStops[busStopIndexPath.row][FAVORITE_BUS_STOP_ID_KEY] integerValue];
    }
    // Segue from a search UIBarButtonItem
    else if ([segue.identifier isEqualToString:SHOW_SEARCH_BUS_STOP_SEGUE_ID]) {
        BusStopViewController *busStopVC = [segue destinationViewController];
        busStopVC.stopID = -1;
    }
}

@end
