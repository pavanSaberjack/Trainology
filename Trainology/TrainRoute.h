//
//  TrainRoute.h
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainStation.h"

@interface TrainRoute : NSObject
@property (nonatomic, strong) TrainStation *station;
@property (nonatomic) NSInteger stationOrder;
@property (nonatomic, strong) NSString *trainName;
@end
