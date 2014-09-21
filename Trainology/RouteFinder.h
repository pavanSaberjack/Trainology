//
//  RouteFinder.h
//  Trainology
//
//  Created by Pavan Itagi on 21/09/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainRoute.h"

@interface RouteFinder : NSObject
- (void)getPossibleRoutesFrom:(NSString *)sourceCode
               andDestination:(NSString *)destinationCode
                 withCallBack:(CallBack)callBack;
@end
