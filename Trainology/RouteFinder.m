//
//  RouteFinder.m
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "RouteFinder.h"
#import "TrainRoute.h"

@implementation RouteFinder
- (void)getPossibleRoutesFrom:(NSString *)sourceCode
               andDestination:(NSString *)destinationCode
                 withCallBack:(CallBack)callBack
{
    NSString *urlString = [NSString stringWithFormat:@"http://54.86.157.245:7474/path?source=%@&destination=%@", sourceCode, destinationCode];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //
        NSError* error;
        id json = [NSJSONSerialization
                         JSONObjectWithData:data
                         
                         options:kNilOptions
                         error:&error];
        
        NSLog(@"%@", json);
        if ([json isKindOfClass:[NSArray class]])
        {
            NSMutableArray *routesArray = [NSMutableArray array];
            
            for (int i = 0; i < [json count]; i++)
            {
                //
                NSDictionary *routeDict = json[i];
                TrainRoute *route = [[TrainRoute alloc] init];
                route.stationOrder = [routeDict[@"order"] integerValue];
                route.trainName = routeDict[@"train"];
                
                TrainStation *station = [[TrainStation alloc] init];
                station.location2D =  CLLocationCoordinate2DMake([routeDict[@"lat"] floatValue], [routeDict[@"lng"] floatValue]);
                
                station.lat = routeDict[@"lat"];
                station.lon = routeDict[@"lng"];
                
                station.name = routeDict[@"name"];
                route.station = station;
                
                [routesArray addObject:route];
            }
            callBack(routesArray, nil);
        }
        else
            callBack(nil, error);
    }];
}

@end
