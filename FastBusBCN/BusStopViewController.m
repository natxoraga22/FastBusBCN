//
//  BusStopViewController.m
//  FastBusBCN
//
//  Created by Natxo Raga on 19/01/14.
//  Copyright (c) 2014 RagaSoft. All rights reserved.
//

#import "BusStopViewController.h"
#import "NextBusesFetcher.h"
#import "FavoriteBusStopsManager.h"
#import "NextBusTableViewCell.h"
#import "UIColor+BusLinesColor.h"


@interface BusStopViewController ()
@property (weak, nonatomic) IBOutlet UITableView *nextBusesTableView;
@property (weak, nonatomic) IBOutlet UILabel *busStopNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UISearchBar *busStopSearchBar;
@property (strong, nonatomic) NextBusesFetcher *nextBusesFetcher;
@property (nonatomic) BOOL tableViewIsEmpty;
@end


@implementation BusStopViewController

#pragma mark - ViewController Lifecycle

static const NSInteger DEFAULT_TOOLBAR_HEIGHT = 44;
static NSString *const SEARCH_LOCALIZED_STRING = @"SEARCH";
static NSString *const BUS_STOP_LOCALIZED_ID = @"BUS_STOP_ID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iAd (only iOS7)
    if ([self respondsToSelector:@selector(setCanDisplayBannerAds:)]) {
        self.canDisplayBannerAds = YES;
    }
    
    // Update UI
    [self updateUI];
    
    // Search bar
    [self setupSearch];
    
    // Conditional setup
    if (self.stopID == -1) {
        [self.busStopSearchBar becomeFirstResponder];
        self.favoriteButton.enabled = NO;
    }
    else [self fetchNextBuses];
}

- (void)setupSearch
{
    self.busStopSearchBar.delegate = self;
    self.busStopSearchBar.placeholder = NSLocalizedString(BUS_STOP_LOCALIZED_ID, @"");
    
    CGRect keyboardToolbarRect = CGRectMake(0, 0, self.view.bounds.size.width, DEFAULT_TOOLBAR_HEIGHT);
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:keyboardToolbarRect];
    UIBarButtonItem *spaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:nil
                                                                                        action:nil];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(SEARCH_LOCALIZED_STRING, @"")
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(searchButtonPressed:)];
    [keyboardToolbar setItems:@[spaceBarButtonItem, searchBarButtonItem]];
    self.busStopSearchBar.inputAccessoryView = keyboardToolbar;
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
        [self updateUI];
    }
}

#pragma mark - UI

static NSString *const BUS_STOP_LOCALIZED_STRING_ID = @"BUS_STOP";
static NSString *const ADD_FAVORITE_LOCALIZED_STRING_ID = @"ADD_FAVORITE";
static NSString *const FAVORITE_BUTTON_ACTIVATED_TITLE = @"★";
static NSString *const FAVORITE_BUTTON_DEACTIVATED_TITLE = @"☆";

- (void)updateUI
{
    // ViewController title
    if (self.stopID == -1) self.title = NSLocalizedString(SEARCH_LOCALIZED_STRING, @"");
    else self.title = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(BUS_STOP_LOCALIZED_STRING_ID, @""),
                                                           (long)self.stopID];
    
    // BusStop title
    if ([FavoriteBusStopsManager busStopWithStopIDisFavorite:self.stopID]) {
        NSDictionary *favoriteBusStop = [FavoriteBusStopsManager favoriteBusStopWithStopID:self.stopID];
        self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
        self.busStopNameLabel.textColor = [UIColor blackColor];
        self.busStopNameLabel.text = favoriteBusStop[FAVORITE_BUS_STOP_CUSTOM_NAME_KEY];
    }
    else {
        self.busStopNameLabel.textAlignment = NSTextAlignmentRight;
        self.busStopNameLabel.textColor = [UIColor blackColor];
        self.busStopNameLabel.text = NSLocalizedString(ADD_FAVORITE_LOCALIZED_STRING_ID, @"");
    }
    
    // Favorite button
    if ([FavoriteBusStopsManager busStopWithStopIDisFavorite:self.stopID])
        [self.favoriteButton setTitle:FAVORITE_BUTTON_ACTIVATED_TITLE forState:UIControlStateNormal];
    else
        [self.favoriteButton setTitle:FAVORITE_BUTTON_DEACTIVATED_TITLE forState:UIControlStateNormal];
}

#pragma mark - Fetching

- (IBAction)refreshPressed:(UIBarButtonItem *)sender
{
    [self fetchNextBuses];
}

- (void)fetchNextBuses
{
    // Activate the network activity indicators
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];
    UIBarButtonItem *activityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = activityBarButtonItem;
    
    // Disable the favorite button
    self.favoriteButton.enabled = NO;
    
    [self.nextBusesFetcher fetchStopNameAndNextBusesForStop:self.stopID];
}

#pragma mark - NextBusesFetcher Data Delegate

static NSString *const WRONG_STOP_LOCALIZED_ERROR_MESSAGE = @"WRONG_STOP";
static NSString *const FAILED_CONNECTION_LOCALIZED_STRING = @"CONNECTION_FAILED";

- (void)nextBusesFetcherDidFinishLoading:(NextBusesFetcher *)nextBusesFetcher
{
    // Bus stop not found
    if (!self.nextBusesFetcher.busStopFound) {
        self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
        self.busStopNameLabel.textColor = [UIColor redColor];
        self.busStopNameLabel.text = NSLocalizedString(WRONG_STOP_LOCALIZED_ERROR_MESSAGE, @"");
    }
    // Bus stop found
    else {
        self.favoriteButton.enabled = YES;
        // TODO: Test! Try to fail a connection and refresh later without failing
        [self updateUI];    // Necessary if we refresh from a failed connection (in order to remove the error message)
    }
    
    [self.nextBusesTableView reloadData];
    
    // Deactivate the network activity indicators
    [self stopShowingNetworkActivityIndicators];
}

- (void)nextBusesFetcherDidFail:(NextBusesFetcher *)nextBusesFetcher
{
    self.busStopNameLabel.textAlignment = NSTextAlignmentLeft;
    self.busStopNameLabel.textColor = [UIColor redColor];
    self.busStopNameLabel.text = NSLocalizedString(FAILED_CONNECTION_LOCALIZED_STRING, @"");
    
    // Deactivate the network activity indicators
    [self stopShowingNetworkActivityIndicators];
}

- (void)stopShowingNetworkActivityIndicators
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Favorites management

- (IBAction)favoriteButtonPressed:(UIButton *)sender
{
    if ([FavoriteBusStopsManager busStopWithStopIDisFavorite:self.stopID]) [self removeFromFavorites];
    else [self askFavoriteCustomName];
}

static NSString *const ALERT_VIEW_LOCALIZED_TITLE = @"NEW_FAVORITE_ALERT_VIEW_TITLE";
static NSString *const ALERT_VIEW_LOCALIZED_MESSAGE = @"NEW_FAVORITE_ALERT_VIEW_MESSAGE";
static NSString *const ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE = @"NEW_FAVORITE_ALERT_VIEW_CANCEL_BUTTON_TITLE";
static NSString *const ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE = @"NEW_FAVORITE_ALERT_VIEW_ACCEPT_BUTTON_TITLE";

- (void)askFavoriteCustomName
{
    UIAlertView *customNameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(ALERT_VIEW_LOCALIZED_TITLE, @"")
                                                              message:NSLocalizedString(ALERT_VIEW_LOCALIZED_MESSAGE, @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(ALERT_VIEW_CANCEL_BUTTON_LOCALIZED_TITLE, @"")
                                                    otherButtonTitles:NSLocalizedString(ALERT_VIEW_ACCEPT_BUTTON_LOCALIZED_TITLE, @""), nil];
    
    customNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [customNameAlert show];
}

- (void)addToFavoritesWithCustomName:(NSString *)customName
{
    [FavoriteBusStopsManager addFavoriteBusStopWithID:self.stopID andCustomName:customName];
    [self updateUI];
}

- (void)removeFromFavorites
{
    [FavoriteBusStopsManager removeFavoriteBusStopWithID:self.stopID];
    [self updateUI];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Accept button
    if (buttonIndex == 1) {
        [self addToFavoritesWithCustomName:[alertView textFieldAtIndex:0].text];
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

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    [self cancelSearch];
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
    
    // Empty UITableView because not buses found?
    if (self.stopID != -1 && numberOfRows == 0) {
        self.tableViewIsEmpty = YES;
        numberOfRows = 1;   // Row used for showing an empty table message
    }
    else self.tableViewIsEmpty = NO;
    
    return numberOfRows;
}

static NSString *const NEXT_BUS_INFO_CELL_ID = @"NextBusInfo";
static NSString *const NEXT_BUS_NOT_FOUND_CELL_ID = @"NextBusNotFound";
static NSString *const IMMINENT_BUS_LOCALIZED_TIME = @"IMMINENT_BUS";
static NSString *const BUS_LOCALIZED_TIME = @"BUS_TIME";

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
            busTimeString = [busTimeString stringByAppendingString:NSLocalizedString(IMMINENT_BUS_LOCALIZED_TIME, @"")];
        }
        else {
            NSString *newTime = [NSString stringWithFormat:@"%@ %@", time, NSLocalizedString(BUS_LOCALIZED_TIME, @"")];
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
