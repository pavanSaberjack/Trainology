//
//  TrainStation.m
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "TrainStation.h"

@interface TrainStation()

@end

@implementation TrainStation

- (void)getNearbyStationForUserForLocation:(CLLocation *)location withCallBack:(CallBack)callBack
{
    CLLocationCoordinate2D location2D = [location coordinate];
    NSString *urlString =  [NSString stringWithFormat:@"http://54.86.157.245:7474/neareststation?latitude=%f&longitude=%f", location2D.latitude, location2D.longitude];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError* error;
                               NSDictionary* json = [NSJSONSerialization
                                                     JSONObjectWithData:data
                                                     
                                                     options:kNilOptions
                                                     error:&error];
                               
                               if (json != nil && json[@"name"] != nil)
                               {
                                   callBack(json[@"name"], nil);
                               }
                               else
                               {
                                   callBack(nil, error);
                               }
                           }];
}
@end
