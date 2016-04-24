//
//  FavouriteBusStopsViewController.m
//  FastBusBCN
//
//  Created by Natxo Raga on 15/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "FavoriteBusStopsTableViewController.h"
#import "FavoriteBusStopsManager.h"
#import "BusStopViewController.h"


@interface FavoriteBusStopsTableViewController()
@property (nonatomic) NSUInteger selectedRowIndex;
@end


@implementation FavoriteBusStopsTableViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iAd (only iOS7)
    if ([self respondsToSelector:@selector(setCanDisplayBannerAds:)]) {
        self.canDisplayBannerAds = YES;
    }
    
    // TableView edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reload the data every time we are going to appear on screen
    // because our data can be modified by other view controllers
    // i.e. BusStopViewController can add favorites
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [FavoriteBusStopsManager favoriteBusStopsCount];
}

static NSString *const FAVORITE_BUS_STOP_CELL_ID = @"FavoriteBusStop";
static NSString *const BUS_STOP_LOCALIZED_STRING = @"BUS_STOP";

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:FAVORITE_BUS_STOP_CELL_ID forIndexPath:indexPath];
    
    BusStop* favoriteBusStop = [FavoriteBusStopsManager favoriteBusStopAtIndex:indexPath.row];
    NSString* busStopIDString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(BUS_STOP_LOCALIZED_STRING, @""),
                                                                    @(favoriteBusStop.identifier)];
    
    // If custom title: Cell Title --> Bus Stop name, Cell Subtitle --> Bus Stop ID
    if (![favoriteBusStop.customName isEqualToString:@""]) {
        cell.textLabel.text = favoriteBusStop.customName;
        cell.detailTextLabel.text = busStopIDString;
    }
    // Otherwise: Cell Title --> Bus Stop ID, no Cell Subtitle
    else {
        cell.textLabel.text = busStopIDString;
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

// Rearranging the UITableView
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [FavoriteBusStopsManager moveFavoriteBusStopFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

// Deleting rows from the UITableView
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [FavoriteBusStopsManager removeFavoriteBusStopAtIndex:indexPath.row];
        
        // UI deleting
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Editing a favorite
static NSString *const ALERT_VIEW_LOCALIZED_TITLE = @"EDIT_FAVORITE_ALERT_VIEW_TITLE";
static NSString *const ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE = @"EDIT_FAVORITE_ALERT_VIEW_CANCEL_BUTTON_TITLE";
static NSString *const ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE = @"EDIT_FAVORITE_ALERT_VIEW_ACCEPT_BUTTON_TITLE";

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRowIndex = indexPath.row;
    UIAlertView *customNameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ALERT_VIEW_LOCALIZED_TITLE, @"")
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE, @"")
                                                    otherButtonTitles:NSLocalizedString(ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE, @""), nil];
    
    customNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    BusStop *favoriteBusStop = [FavoriteBusStopsManager favoriteBusStopAtIndex:indexPath.row];
    [customNameAlert textFieldAtIndex:0].text = favoriteBusStop.customName;
    [customNameAlert show];
}

- (void)editFavoriteWithCustomName:(NSString *)customName
{
    [FavoriteBusStopsManager setCustomName:customName forFavoriteBusStopAtIndex:self.selectedRowIndex];
    [self.tableView reloadData];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Accept button
    if (buttonIndex == 1) {
        [self editFavoriteWithCustomName:[alertView textFieldAtIndex:0].text];
    }
}

#pragma mark - Navigation

static NSString *const SHOW_NEXT_BUSES_SEGUE_ID = @"ShowNextBuses";
static NSString *const SHOW_SEARCH_BUS_STOP_SEGUE_ID = @"ShowSearchBusStop";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BusStopViewController *busStopVC = [segue destinationViewController];
    
    // Segue from a UITableView row
    if ([segue.identifier isEqualToString:SHOW_NEXT_BUSES_SEGUE_ID]) {
        NSIndexPath *busStopIndexPath = [self.tableView indexPathForSelectedRow];
        BusStop *favoriteBusStop = [FavoriteBusStopsManager favoriteBusStopAtIndex:busStopIndexPath.row];
        busStopVC.stopID = favoriteBusStop.identifier;
    }
    // Segue from a search UIBarButtonItem
    else if ([segue.identifier isEqualToString:SHOW_SEARCH_BUS_STOP_SEGUE_ID]) {
        busStopVC.stopID = -1;
    }
}

@end
