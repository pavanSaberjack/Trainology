//
//  ViewController.m
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(showMapView) withObject:nil afterDelay:0.3];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMapView
{
    MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [self presentViewController:mapView animated:YES completion:nil];
}
@end
