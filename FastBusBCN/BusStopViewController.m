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
#import "UIColor+BusLinesColor.h"


@interface BusStopViewController ()
@property (weak, nonatomic) IBOutlet UITableView *nextBusesTableView;
@property (weak, nonatomic) IBOutlet UILabel *busStopNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UISearchBar *busStopSearchBar;
@property (strong, nonatomic) NextBusesFetcher *nextBusesFetcher;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL tableViewIsEmpty;
@end


@implementation BusStopViewController

// Keys used in order to acces the favorite bus stop dictionary
NSString *const FAVORITE_BUS_STOPS_KEY = @"FavoriteBusStops";
NSString *const FAVORITE_BUS_STOP_ID_KEY = @"FavoriteBusStopID";
NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY = @"FavoriteBusStopCustomName";

#pragma mark - ViewController Lifecycle

static const NSInteger DEFAULT_TOOLBAR_HEIGHT = 44;
static NSString *const SEARCH_LOCALIZED_STRING_ID = @"SEARCH";
static NSString *const BUS_STOP_LOCALIZED_ID_ID = @"BUS_STOP_ID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iAd
    self.canDisplayBannerAds = YES;
    
    // Update UI
    [self updateUI];
    
    // Search bar
    self.busStopSearchBar.delegate = self;
    self.busStopSearchBar.placeholder = NSLocalizedString(BUS_STOP_LOCALIZED_ID_ID, @"");
    CGRect keyboardToolbarRect = CGRectMake(0, 0, self.view.bounds.size.width, DEFAULT_TOOLBAR_HEIGHT);
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:keyboardToolbarRect];
    UIBarButtonItem *spaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:nil
                                                                                        action:nil];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(SEARCH_LOCALIZED_STRING_ID, @"")
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(searchButtonPressed:)];
    [keyboardToolbar setItems:@[spaceBarButtonItem, searchBarButtonItem]];
    self.busStopSearchBar.inputAccessoryView = keyboardToolbar;
    
    // Conditional setup
    if (self.stopID == -1) {
        [self.busStopSearchBar becomeFirstResponder];
        self.favoriteButton.enabled = NO;
    }
    else [self fetchNextBuses];
}

#pragma mark - Getters & Setters

- (NextBusesFetcher *)nextBusesFetcher
{
    if (!_nextBusesFetcher) {
        _nextBusesFetcher = [[NextBusesFetcher alloc] init];
        _nextBusesFetcher.delegate = self;
    }
    return _nextBusesFetcher;
}

- (void)setStopID:(NSInteger)stopID
{
    if (_stopID != stopID) {
        _stopID = stopID;
        [self updateIsFavorite];
        [self updateUI];
    }
}

- (void)setIsFavorite:(BOOL)isFavorite
{
    if (_isFavorite != isFavorite) {
        _isFavorite = isFavorite;
        [self updateUI];
    }
}

- (void)updateIsFavorite
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *favoriteBusStops = [userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY];
    BOOL found = NO;
    for (NSDictionary *favoriteBusStop in favoriteBusStops) {
        if ([favoriteBusStop[FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(self.stopID)]) {
            found = YES;
            self.isFavorite = YES;
        }
    }
    if (!found) self.isFavorite = NO;
}

#pragma mark - UI

static NSString *const BUS_STOP_LOCALIZED_STRING_ID = @"BUS_STOP";
static NSString *const ADD_FAVORITE_LOCALIZED_STRING_ID = @"ADD_FAVORITE";
static NSString *const FAVORITE_BUTTON_ACTIVATED_TITLE = @"★";
static NSString *const FAVORITE_BUTTON_DEACTIVATED_TITLE = @"☆";

- (void)updateUI
{
    // ViewController title
    if (self.stopID == -1) self.title = NSLocalizedString(SEARCH_LOCALIZED_STRING_ID, @"");
    else self.title = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(BUS_STOP_LOCALIZED_STRING_ID, @""),
                                                           self.stopID];
    
    // BusStop title
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *favoriteBusStops = [userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY];
    BOOL found = NO;
    for (NSDictionary *favoriteBusStop in favoriteBusStops) {
        if ([favoriteBusStop[FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(self.stopID)]) {
            found = YES;
            self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
            self.busStopNameLabel.textColor = [UIColor blackColor];
            self.busStopNameLabel.text = favoriteBusStop[FAVORITE_BUS_STOP_CUSTOM_NAME_KEY];
        }
    }
    if (!found) {
        self.busStopNameLabel.textAlignment = NSTextAlignmentRight;
        self.busStopNameLabel.textColor = [UIColor blackColor];
        self.busStopNameLabel.text = NSLocalizedString(ADD_FAVORITE_LOCALIZED_STRING_ID, @"");
    }
    
    // Favorite button
    if (self.isFavorite) [self.favoriteButton setTitle:FAVORITE_BUTTON_ACTIVATED_TITLE forState:UIControlStateNormal];
    else [self.favoriteButton setTitle:FAVORITE_BUTTON_DEACTIVATED_TITLE forState:UIControlStateNormal];
}

#pragma mark - Fetching

- (IBAction)refreshPressed:(UIBarButtonItem *)sender
{
    [self fetchNextBuses];
}

- (void)fetchNextBuses
{
    [self.nextBusesFetcher fetchStopNameAndNextBusesForStop:self.stopID];
    
    // Disable the favorite button
    self.favoriteButton.enabled = NO;
    
    // Put a UIActivityIndicatorView on the NavigationBar
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];
    UIBarButtonItem *activityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = activityBarButtonItem;
}

#pragma mark - NextBusesFetcher Data Delegate

static NSString *const WRONG_STOP_LOCALIZED_ERROR_MESSAGE_ID = @"WRONG_STOP";
static NSString *const FAILED_CONNECTION_LOCALIZED_ID = @"CONNECTION_FAILED";

- (void)nextBusesFetcherDidFinishLoading:(NextBusesFetcher *)nextBusesFetcher
{
    // Bus stop not found
    if (!self.nextBusesFetcher.busStopFound) {
        self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
        self.busStopNameLabel.textColor = [UIColor redColor];
        self.busStopNameLabel.text = NSLocalizedString(WRONG_STOP_LOCALIZED_ERROR_MESSAGE_ID, @"");
    }
    // Bus stop found
    else {
        self.favoriteButton.enabled = YES;
        // TODO: Test! Try to fail a connection and refresh later without failing
        [self updateUI];    // Necessary if we refresh from a failed connection (in order to remove the error message)
    }
    
    [self.nextBusesTableView reloadData];
    
    // Replace the UIActivityIndicatorView with a refresh button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)nextBusesFetcherDidFail:(NextBusesFetcher *)nextBusesFetcher
{
    self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
    self.busStopNameLabel.textColor = [UIColor redColor];
    self.busStopNameLabel.text = NSLocalizedString(FAILED_CONNECTION_LOCALIZED_ID, @"");
    
    // Replace the UIActivityIndicatorView with a refresh button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Favorites management

- (IBAction)favoriteButtonPressed:(UIButton *)sender
{
    if (self.isFavorite) [self removeFromFavorites];
    else [self addToFavorites];
}

static NSString *const ALERT_VIEW_LOCALIZED_TITLE_ID = @"CUSTOM_NAME_ALERT_VIEW_TITLE";
static NSString *const ALERT_VIEW_LOCALIZED_MESSAGE_ID = @"CUSTOM_NAME_ALERT_VIEW_MESSAGE";
static NSString *const ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE_ID = @"CUSTOM_NAME_ALERT_VIEW_CANCEL_BUTTON_TITLE";
static NSString *const ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE_ID = @"CUSTOM_NAME_ALERT_VIEW_ACCEPT_BUTTON_TITLE";

- (void)addToFavorites
{
    UIAlertView *customNameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ALERT_VIEW_LOCALIZED_TITLE_ID, @"")
                                                              message:NSLocalizedString(ALERT_VIEW_LOCALIZED_MESSAGE_ID, @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE_ID, @"")
                                                    otherButtonTitles:NSLocalizedString(ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE_ID, @""), nil];
    customNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [customNameAlert textFieldAtIndex:0].text = self.busStopNameLabel.text;
    [customNameAlert show];
}

- (void)removeFromFavorites
{
    self.isFavorite = NO;
    
    // Remove favorite from NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    
    NSInteger index = -1;
    for (int i = 0; i < [favoriteBusStops count]; i++) {
        NSDictionary *favoriteBusStop = favoriteBusStops[i];
        if ([favoriteBusStop[FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(self.stopID)]) {
            index = i;
        }
    }
    [favoriteBusStops removeObjectAtIndex:index];
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Accept button
    if (buttonIndex == 1) {
        // Add favorite to NSUserDefaults with the custom name
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
        if (!favoriteBusStops) favoriteBusStops = [[NSMutableArray alloc] init];
        [favoriteBusStops addObject:@{FAVORITE_BUS_STOP_ID_KEY: @(self.stopID),
                                      FAVORITE_BUS_STOP_CUSTOM_NAME_KEY: [alertView textFieldAtIndex:0].text}];
        [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
        [userDefaults synchronize];
        
        self.isFavorite = YES;
    }
}

#pragma mark - Search management

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender
{
    self.stopID = [self.busStopSearchBar.text integerValue];

    // "Cancel" the search
    [self cancelSearch];
    
    [self fetchNextBuses];
}

- (void)cancelSearch
{
    self.busStopSearchBar.text = @"";
    self.busStopSearchBar.showsCancelButton = NO;
    [self.view endEditing:YES];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.busStopSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *nextBuses = [self.nextBusesFetcher busStopInfo][FETCHED_NEXT_BUSES_KEY];
    NSInteger numberOfRows = 0;
    if (nextBuses != nil) numberOfRows = [nextBuses count];
    
    // Empty UITableView?
    if (numberOfRows == 0) {
        self.tableViewIsEmpty = YES;
        numberOfRows = 1;   // Row used for showing an empty table message
    }
    else self.tableViewIsEmpty = NO;
    
    return numberOfRows;
}

static NSString *const NEXT_BUS_INFO_CELL_ID = @"NextBusInfo";
static NSString *const NEXT_BUS_NOT_FOUND_CELL_ID = @"NextBusNotFound";
static NSString *const IMMINENT_BUS_LOCALIZED_TIME_ID = @"IMMINENT_BUS";
static NSString *const BUS_LOCALIZED_TIME_ID = @"BUS_TIME";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Empty table
    if (self.tableViewIsEmpty) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEXT_BUS_NOT_FOUND_CELL_ID forIndexPath:indexPath];
        return cell;
    }
    
    NextBusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEXT_BUS_INFO_CELL_ID forIndexPath:indexPath];
    NSDictionary *nextBus = [self.nextBusesFetcher busStopInfo][FETCHED_NEXT_BUSES_KEY][indexPath.row];
    
    // Bus line
    cell.nextBusLineLabel.text = nextBus[FETCHED_NEXT_BUS_LINE_KEY];
    cell.nextBusLineLabel.backgroundColor = [self lineColorForLine:nextBus[FETCHED_NEXT_BUS_LINE_KEY]];
    
    // Bus time
    NSString *busTimeString = @"";
    BOOL first = YES;
    for (NSNumber *time in nextBus[FETCHED_NEXT_BUS_TIME_KEY]) {
        // Comma separator between times
        if (first) first = NO;
        else busTimeString = [busTimeString stringByAppendingString:@", "];
        // Time itself
        if ([time integerValue] == 0) {
            busTimeString = [busTimeString stringByAppendingString:NSLocalizedString(IMMINENT_BUS_LOCALIZED_TIME_ID, @"")];
        }
        else {
            NSString *newTime = [NSString stringWithFormat:@"%@ %@", time, NSLocalizedString(BUS_LOCALIZED_TIME_ID, @"")];
            busTimeString = [busTimeString stringByAppendingString:newTime];
        }
    }
    cell.nextBusTimeLabel.text = busTimeString;

    return cell;
}

static NSString *const BAIXBUS_LINE_PREFIX = @"L";
static NSString *const NITBUS_LINE_PREFIX = @"N";
static NSString *const VERTICAL_BUS_LINE_PREFIX = @"V";
static NSString *const HORITZONTAL_BUS_LINE_PREFIX = @"H";
static NSString *const DIAGONAL_BUS_LINE_PREFIX = @"D";

- (UIColor *)lineColorForLine:(NSString *)busLine
{
    NSRange firstDigitRange = [busLine rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890"]];
    NSString *prefix = @"";
    if (firstDigitRange.location == NSNotFound) prefix = busLine;
    else prefix = [busLine substringToIndex:firstDigitRange.location];
    
    // TODO: Add colors
    UIColor *busLineColor = [UIColor defaultBusLineColor];
    if ([prefix isEqualToString:BAIXBUS_LINE_PREFIX]) busLineColor = [UIColor baixBusLineColor];
    else if ([prefix isEqualToString:NITBUS_LINE_PREFIX]) busLineColor = [UIColor nitBusLineColor];
    else if ([prefix isEqualToString:VERTICAL_BUS_LINE_PREFIX]) busLineColor = [UIColor vBusLineColor];
    else if ([prefix isEqualToString:HORITZONTAL_BUS_LINE_PREFIX]) busLineColor = [UIColor hBusLineColor];
    else if ([prefix isEqualToString:DIAGONAL_BUS_LINE_PREFIX]) busLineColor = [UIColor dBusLineColor];
    
    return busLineColor;
}

@end
