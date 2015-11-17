//
//  JRTEditIPAddressViewController.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;
@import CoreData.NSManagedObjectContext;
@class  JRTIPAddress;
@class JRTIPAddressesController;

@interface JRTEditIPAddressViewController : UIViewController

/*!
 @property JRTIPAddress * IPAddress;
 Upon setting this property, the UI will be updated to reflect the contents of
 the instance and any changes to the fields will be save to this instance. The
 property managedObjectContext will be set to nil without saving.
 */
@property (nonatomic, strong) JRTIPAddress * IPAddress;

/*!
 @property NSManagedObjectContext * managedObjectContext
 Upon setting this property, the viewController will set the property 
 IPAddress to nil, and use this managedObjectContext to create a new IP when
 the user enters text in the fields.
 @note
 The receiver will call methods on this managedObjectContext on the mainqueue, 
 without calling 'performBlock'. This managedObjectContext must therefor have
 a concurrency of type MainQueue.
 */
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) JRTIPAddressesController * IPAddressesController;
@end
