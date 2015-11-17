//
//  JRTIPAddress+CoreDataProperties.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "JRTIPAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface JRTIPAddress (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ipAddress;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *modificationDate;
@property (nullable, nonatomic, retain) NSNumber *isSelected;

@end

NS_ASSUME_NONNULL_END
