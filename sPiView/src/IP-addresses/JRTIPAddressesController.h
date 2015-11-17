//
//  JRTIPAddressesController.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import Foundation;
@import CoreData.NSManagedObjectContext;
@class JRTIPAddress;

@interface JRTIPAddressesController : NSObject
@property (nonatomic, readonly) NSManagedObjectContext * mainQueueContext;

/*!
 @method - (void) setIPAddressSelected: (JRTIPAddress *) IPAddress
 This method will set the given argument's isSelected property to YES. It will
 also make sure all other JRTIPAddress instances have the isSelected property
 set to NO.
 @param IPAddress
 An instance of JRTIPAddress that should get the isSelected property to be YES.
 */
- (void) setIPAddressSelected: (JRTIPAddress *) IPAddress;

/*
 @method - (JRTIPAddress *) selectedIPAddressMainQueueContext
 This method executes a sycnhronous fetchrequest on the mainQueueContext to
 retrieve the IP address that is selected.
 @return JRTIPAddress
 An instance of JRTIPAddress bound to the receivers mainQueueContext. Might be
 nil if no selected IP address could be found.
 */
- (JRTIPAddress *) selectedIPAddressMainQueueContext;
@end
