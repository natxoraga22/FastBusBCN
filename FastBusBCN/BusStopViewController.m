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
@end


@implementation BusStopViewController

// Keys used in order to acces the favorite bus stop dictionary
NSString *const FAVORITE_BUS_STOPS_KEY = @"FavoriteBusStops";
NSString *const FAVORITE_BUS_STOP_ID_KEY = @"FavoriteBusStopID";
NSString *const FAVORITE_BUS_STOP_NAME_KEY = @"FavoriteBusStopName";
NSString *const FAVORITE_BUS_STOP_CUSTOM_NAME_KEY = @"FavoriteBusStopCustomName";

#pragma mark - ViewController Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSInteger const DEFAULT_TOOLBAR_HEIGHT = 44;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Favorite button
    [self updateFavoriteButtonImage];
    
    // Search bar
    self.busStopSearchBar.delegate = self;
    CGRect keyboardToolbarRect = CGRectMake(0, 0, self.view.bounds.size.width, DEFAULT_TOOLBAR_HEIGHT);
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:keyboardToolbarRect];
    UIBarButtonItem *spaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                target:nil
                                                                                                action:nil];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Buscar"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(searchButtonPressed:)];
    [keyboardToolbar setItems:@[spaceBarButtonItem, searchBarButtonItem]];
    self.busStopSearchBar.inputAccessoryView = keyboardToolbar;
    
    // Next buses fetching
    self.nextBusesFetcher = [[NextBusesFetcher alloc] init];
    self.nextBusesFetcher.delegate = self;
    [self fetchNextBuses];
}

#pragma mark - Setters

- (void)setStopID:(NSInteger)stopID
{
    if (_stopID != stopID) {
        _stopID = stopID;
        self.title = [NSString stringWithFormat:@"Parada %d", self.stopID];
        [self updateIsFavorite];
    }
}

- (void)setIsFavorite:(BOOL)isFavorite
{
    if (_isFavorite != isFavorite) {
        _isFavorite = isFavorite;
        [self updateFavoriteButtonImage];
    }
}

- (void)updateIsFavorite
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *favoriteBusStops = [userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY];
    BOOL found = NO;
    for (NSDictionary *favoriteBusStop in favoriteBusStops) {
        if ([[favoriteBusStop objectForKey:FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(self.stopID)]) {
            found = YES;
            self.isFavorite = YES;
        }
    }
    if (!found) self.isFavorite = NO;
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

#pragma mark - Favorites management

- (IBAction)favoriteButtonPressed:(UIButton *)sender
{
    if (self.isFavorite) {
        self.isFavorite = NO;
        [self removeFromFavorites];
    }
    else {
        self.isFavorite = YES;
        [self addToFavorites];
    }
}

- (void)addToFavorites
{
    // Add favorite to NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    // TODO: ADD CUSTOM NAME
    [favoriteBusStops addObject:@{FAVORITE_BUS_STOP_ID_KEY: @(self.stopID),
                                  FAVORITE_BUS_STOP_NAME_KEY: [[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_BUS_STOP_NAME_KEY],
                                  FAVORITE_BUS_STOP_CUSTOM_NAME_KEY: @""}];
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

- (void)removeFromFavorites
{
    // Remove favorite from NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteBusStops = [[userDefaults objectForKey:FAVORITE_BUS_STOPS_KEY] mutableCopy];
    
    NSInteger index = -1;
    for (int i = 0; i < [favoriteBusStops count]; i++) {
        NSDictionary *favoriteBusStop = [favoriteBusStops objectAtIndex:i];
        if ([[favoriteBusStop objectForKey:FAVORITE_BUS_STOP_ID_KEY] isEqualToNumber:@(self.stopID)]) {
            index = i;
        }
    }
    [favoriteBusStops removeObjectAtIndex:index];
    [userDefaults setObject:[favoriteBusStops copy] forKey:FAVORITE_BUS_STOPS_KEY];
    [userDefaults synchronize];
}

- (void)updateFavoriteButtonImage
{
    UIImage *favoriteButtonImage;
    if (self.isFavorite) {
        favoriteButtonImage = [[UIImage imageNamed:@"FavoriteIconFull.png"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else {
        favoriteButtonImage = [[UIImage imageNamed:@"FavoriteIconEmpty.png"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [self.favoriteButton setImage:favoriteButtonImage forState:UIControlStateNormal];
}

#pragma mark - Search management

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender
{
    self.stopID = [self.busStopSearchBar.text integerValue];

    // "Cancel" the search
    self.busStopSearchBar.text = @"";
    [self.view endEditing:YES];
    
    [self fetchNextBuses];
}

#pragma mark - NextBusesFetcher Data Delegate

- (void)nextBusesFetcherDidFinishLoading:(NextBusesFetcher *)nextBusesFetcher
{
    self.busStopNameLabel.text = [[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_BUS_STOP_NAME_KEY];
    [self.nextBusesTableView reloadData];
    
    // Enable the favorite button
    self.favoriteButton.enabled = YES;
    
    // Replace the UIActivityIndicatorView with a refresh button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshPressed:)];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *nextBuses = [[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_NEXT_BUSES_KEY];
    if (nextBuses == nil) return 0;
    return [nextBuses count];
}

static NSString *const IMMINENT_BUS_TIME = @"Inminente";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NextBusInfo";
    NextBusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *nextBus = [[[self.nextBusesFetcher busStopInfo] objectForKey:FETCHED_NEXT_BUSES_KEY] objectAtIndex:indexPath.row];
    
    // Bus line
    cell.nextBusLineLabel.text = [nextBus objectForKey:FETCHED_NEXT_BUS_LINE_KEY];
    cell.nextBusLineLabel.backgroundColor = [self lineColorForLine:[nextBus objectForKey:FETCHED_NEXT_BUS_LINE_KEY]];
    
    // Bus time
    NSString *busTimeString = @"";
    BOOL first = YES;
    for (NSNumber *time in [nextBus objectForKey:FETCHED_NEXT_BUS_TIME_KEY]) {
        if (first) first = NO;
        else busTimeString = [busTimeString stringByAppendingString:@", "];
        NSString *timeString = @"";
        if ([time integerValue] == 0) timeString = IMMINENT_BUS_TIME;
        else timeString = [NSString stringWithFormat:@"%@ min", time];
        busTimeString = [busTimeString stringByAppendingString:timeString];
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
    UIColor *busLineColor = [UIColor defaultBusLineColor];
    NSRange firstDigitRange = [busLine rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890"]];
    NSString *prefix = @"";
    if (firstDigitRange.location == NSNotFound) prefix = busLine;
    else prefix = [busLine substringToIndex:firstDigitRange.location];
    
    // TODO: ADD COLORS
    if ([prefix isEqualToString:BAIXBUS_LINE_PREFIX]) busLineColor = [UIColor baixBusLineColor];
    else if ([prefix isEqualToString:NITBUS_LINE_PREFIX]) busLineColor = [UIColor nitBusLineColor];
    else if ([prefix isEqualToString:VERTICAL_BUS_LINE_PREFIX]) busLineColor = [UIColor vBusLineColor];
    else if ([prefix isEqualToString:HORITZONTAL_BUS_LINE_PREFIX]) busLineColor = [UIColor hBusLineColor];
    else if ([prefix isEqualToString:DIAGONAL_BUS_LINE_PREFIX]) busLineColor = [UIColor dBusLineColor];
    
    return busLineColor;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.busStopSearchBar.text = @"";
    [self.view endEditing:YES];
}

@end
