//
//  MapViewController.m
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "TrainStation.h"
#import "TrainRoute.h"
#import "RouteFinder.h"

@interface MapViewController ()<UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITextField *sourceField;
@property (nonatomic, weak) IBOutlet UITextField *destinationField;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *hintsTableView;

@property (nonatomic, strong) CLLocationManager *currentLocationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, retain) MKPolyline *routeLine; //your line
@property (nonatomic, retain) MKPolylineView *routeLineView;

@property (nonatomic, strong) NSMutableArray *routesArray;
@property (nonatomic, strong) NSMutableDictionary *stationsCodeDict;
@property (nonatomic, strong) NSMutableArray *autocompleteNames;
@property (nonatomic, strong) NSMutableArray *allTheStationNameArray;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _allTheStationNameArray = [NSMutableArray array];
    _autocompleteNames = [NSMutableArray array];
    [_hintsTableView setHidden:YES];
    
    [self getUserLocation];
    
    [self readFile];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchTrains:(id)sender
{
    NSLog(@"Search trains");
    
    NSString *fromCode = [self.stationsCodeDict valueForKey:self.sourceField.text];
    NSString *toCode = [self.stationsCodeDict valueForKey:self.destinationField.text];
    
    RouteFinder *route = [[RouteFinder alloc] init];
    [route getPossibleRoutesFrom:fromCode andDestination:toCode withCallBack:^(id data, NSError *error) {
        // update UI for route
        [self drawRouteForRoutes:data];
    }];
}

#pragma mark - Private methods
- (NSString *)modifyStringForDisplay:(NSString *)string
{
    // check for space at the end
    if ([[string substringFromIndex:string.length-1] isEqualToString:@" "]) {
        string = [string substringToIndex:string.length -1];
    }
    return [string capitalizedString];
}

- (void)readFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"station_codes" ofType:@"csv"];;
    NSString *dataStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *stationsArray = [dataStr componentsSeparatedByString: @"\n"];
   
    [self.allTheStationNameArray removeAllObjects];
    
    
    self.stationsCodeDict = [NSMutableDictionary dictionary];
    for (NSString *str in stationsArray)
    {
        NSArray *array = [str componentsSeparatedByString:@","];
        if ([array count] >= 2) {
            NSString *modifiedKey = [self modifyStringForDisplay:array[0]];
            self.stationsCodeDict[modifiedKey] = array[1];
        } 
    }
    
    [self.allTheStationNameArray addObjectsFromArray:self.stationsCodeDict.allKeys];
}

- (void)drawRouteForRoutes:(NSArray *)routesArray
{
    CLLocationCoordinate2D coordinateArray[[routesArray count]];
    for (int i = 0; i< [routesArray count]; i++)
    {
        TrainRoute *route = routesArray[i];
        coordinateArray[i] = CLLocationCoordinate2DMake([route.station.lat floatValue], [route.station.lon floatValue]);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake([route.station.lat floatValue], [route.station.lon floatValue]);
        point.title = route.station.name;
        if (route.trainName != nil)
        {            
            point.subtitle = route.trainName;
        }
        [self.mapView addAnnotation:point];
    }
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:[routesArray count]];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]]; //If you want the route to be visible
    [self.mapView addOverlay:self.routeLine];
}

- (void)getUserLocation
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization]; // this is the way we have to request in iOS 8 (get location only when the app is in fore ground)
    }
    
    self.currentLocationManager = locationManager;
    self.currentLocationManager.delegate = self;
    [self.currentLocationManager startUpdatingLocation];
}

- (void)updateLocation:(CLLocation *)location {
    if (location) {
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        CLLocationCoordinate2D loc = [location coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 500, 500);
        [self.mapView setRegion:region animated:YES];
    }
}


#pragma mark - API calls
- (void)getNearbyStationForUser
{
    typeof(self) __weak weakself = self;
    TrainStation *station = [[TrainStation alloc] init];
    [station getNearbyStationForUserForLocation:self.currentLocation withCallBack:^(id data, NSError *error) {
        if (error == nil && data != nil)
        {
            if ([weakself.sourceField text] != nil && [[weakself.sourceField text] isEqualToString:@""])
            {
                [weakself.sourceField setText:[weakself modifyStringForDisplay:data]];
            }
        }
    }];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.sourceField)
    {
        [self.destinationField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self searchTrains:nil];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.hintsTableView.hidden = NO;
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [self.autocompleteNames removeAllObjects];
    for(NSString *curString in self.allTheStationNameArray) {
        NSRange substringRange = [curString rangeOfString:substring options:NSCaseInsensitiveSearch];
        if (substringRange.location == 0) {
            [self.autocompleteNames addObject:curString];
        }
    }
    [self.hintsTableView reloadData];
}

#pragma mark - MKMapViewDelegate methods

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == self.routeLine)
    {
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 5;
        }
        return self.routeLineView;
    }
    
    return nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 0) {
        [self.currentLocationManager stopUpdatingLocation];
        
        CLLocation *location = locations[0];
        self.currentLocation = location;
        [self updateLocation:location];
        
        [self getNearbyStationForUser];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"CLLocationManager: didFailWithError: %@", error);
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSLog(@"\n\n\t\t*** Location Authorization Denied ***\n\n");
        self.currentLocation = nil;
        [manager requestWhenInUseAuthorization];
    }
}

- (NSString *)getStringForIndex:(NSInteger)index
{
    NSString * str = self.autocompleteNames[index];
    return [[str componentsSeparatedByString:@","] objectAtIndex:0];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.autocompleteNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:[self getStringForIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [self getStringForIndex:indexPath.row];
    if ([self.sourceField isFirstResponder])
    {
        [self.sourceField setText:str];
    }
    else
    {
        [self.destinationField setText:str];
    }
    
    [tableView setHidden:YES];
}
@end
