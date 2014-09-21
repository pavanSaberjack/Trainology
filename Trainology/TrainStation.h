//
//  TrainStation.h
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^CallBack)(id data, NSError *error);

@interface TrainStation : NSObject
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D location2D;

- (void)getNearbyStationForUserForLocation:(CLLocation *)location
                              withCallBack:(CallBack)callBack;
@end
