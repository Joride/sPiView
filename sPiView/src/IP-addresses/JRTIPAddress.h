//
//  JRTIPAddress.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRTIPAddress : NSManagedObject
+ (JRTIPAddress *) newIPAddressInManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
@end

NS_ASSUME_NONNULL_END

#import "JRTIPAddress+CoreDataProperties.h"
