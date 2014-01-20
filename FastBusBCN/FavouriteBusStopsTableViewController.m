//
//  FavouriteBusStopsViewController.m
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "FavouriteBusStopsTableViewController.h"
#import "BusStopViewController.h"


@interface FavouriteBusStopsTableViewController ()

@end


@implementation FavouriteBusStopsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TEST
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@[@{FAVORITE_BUS_STOP_ID_KEY: @941,
                                FAVORITE_BUS_STOP_NAME_KEY: @"Gran Via - Mandoni",
                                FAVORITE_BUS_STOP_CUSTOM_NAME_KEY: @"Mandoni --> Pl.Espanya"},
                              @{FAVORITE_BUS_STOP_ID_KEY: @108,
                                FAVORITE_BUS_STOP_NAME_KEY: @"Pl. Espanya - FGC",
                                FAVORITE_BUS_STOP_CUSTOM_NAME_KEY: @""}]
                     forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reload the data everytime we are going to appear on screen
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *favoriteBusStops = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
    if (favoriteBusStops == nil) return 0;
    return [favoriteBusStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteBusStop";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *favoriteBusStop = [[[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY] objectAtIndex:indexPath.row];
    if ([[favoriteBusStop objectForKey:FAVORITE_BUS_STOP_CUSTOM_NAME_KEY] isEqualToString:@""]) {
        cell.textLabel.text = [favoriteBusStop objectForKey:FAVORITE_BUS_STOP_NAME_KEY];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Parada %@", [favoriteBusStop objectForKey:FAVORITE_BUS_STOP_ID_KEY]];
    }
    else {
        cell.textLabel.text = [favoriteBusStop objectForKey:FAVORITE_BUS_STOP_CUSTOM_NAME_KEY];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Parada %@: %@", [favoriteBusStop objectForKey:FAVORITE_BUS_STOP_ID_KEY],
                                                                                 [favoriteBusStop objectForKey:FAVORITE_BUS_STOP_NAME_KEY]];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *favoriteBusStops = [[[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    NSDictionary *movingBusStop = [favoriteBusStops objectAtIndex:fromIndexPath.row];
    [favoriteBusStops removeObjectAtIndex:fromIndexPath.row];
    [favoriteBusStops insertObject:movingBusStop atIndex:toIndexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *favoriteBusStops = [[[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
        [favoriteBusStops removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowNextBuses"]) {
        BusStopViewController *busStopVC = [segue destinationViewController];
        NSIndexPath *busStopIndexPath = [self.tableView indexPathForSelectedRow];
        NSArray *favoriteBusStops = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_BUS_STOPS_KEY];
        busStopVC.stopID = [[[favoriteBusStops objectAtIndex:busStopIndexPath.row] objectForKey:FAVORITE_BUS_STOP_ID_KEY] integerValue];
    }
}

@end
