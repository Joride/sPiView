//
//  JRTIPAddressesController.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import CoreData;

#import "NSManagedObjectContext+Persisting.h"
#import "NSFileManager+ApplicationDirectories.h"
#import "JRTIPAddressesController.h"
#import "JRTIPAddress.h"

NSString * const kManagedObjectModelNameIPAddresses   = @"IP-addresses";
NSString * const kPersistentStoreFileNameIPAddresses  = @"IP-addresses.sqlite";
NSString * const kDataModelExtensionIPAddresses       = @"momd";


@interface JRTIPAddressesController ()
@property (nonatomic, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext * privateQueueContext;
@end

@implementation JRTIPAddressesController
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        if (nil != self.persistentStoreCoordinator)
        {
            _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        }
        else
        {
            DebugLog(@"ERROR: no persistent store coordinator in %@",
                     NSStringFromClass([self class]));
        }
    }
    return self;
}
@synthesize privateQueueContext = _privateQueueContext;
-(NSManagedObjectContext *)privateQueueContext
{
    if (nil == _privateQueueContext)
    {
        _privateQueueContext = [[NSManagedObjectContext alloc]
                                initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        _privateQueueContext.parentContext = self.mainQueueContext;
    }
    return _privateQueueContext;
}

#pragma mark - Core Data
@synthesize managedObjectModel = _managedObjectModel;
- (NSManagedObjectModel *)managedObjectModel
{
    if (nil == _managedObjectModel)
    {
        NSURL * modelURL = [[NSBundle mainBundle] URLForResource: kManagedObjectModelNameIPAddresses
                                                   withExtension: kDataModelExtensionIPAddresses];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (nil == _persistentStoreCoordinator)
    {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError * error = nil;
        NSURL * appSupportURL = [fileManager applicationSupportURLError: &error];
        if (nil == error)
        {
            NSURL * storeURL = [appSupportURL URLByAppendingPathComponent: kPersistentStoreFileNameIPAddresses];
            NSError *persistentStoreError = nil;
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                           initWithManagedObjectModel:[self managedObjectModel]];

            NSDictionary * options;
            options = @{NSPersistentStoreFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication,
                        NSMigratePersistentStoresAutomaticallyOption : @(YES),
                        NSInferMappingModelAutomaticallyOption : @(YES)};
            if (nil == [_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                 configuration: nil
                                                                           URL: storeURL
                                                                       options: options
                                                                         error: &persistentStoreError])
            {
                NSCAssert(NO, @"Error adding persistent store to persistentStoreCoordinator in %@: %@",
                          NSStringFromClass([self class]),
                          persistentStoreError);
            }
        }
        else
        {
            DebugLog(@"ERROR getting applicationSupportURL in %@: %@",
                     NSStringFromClass([self class]),
                     error);
        }

    }
    return  _persistentStoreCoordinator;
}
- (void) setIPAddressSelected: (JRTIPAddress *) IPAddress
{
    NSFetchRequest * fetchForIPAddress;
    fetchForIPAddress = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass([JRTIPAddress class])];
    fetchForIPAddress.predicate = [NSPredicate predicateWithFormat: @"isSelected == %@",
                                   @(YES)];
    [self.privateQueueContext performBlock:^{
        NSError * error = nil;
        NSArray * IPAddresses;
        IPAddresses = [self.privateQueueContext executeFetchRequest: fetchForIPAddress
                                                              error: &error];
        if (nil == IPAddresses)
        {
            DebugLog(@"ERROR executing fetchreqeust in %@: %@",
                     NSStringFromClass([self class]),
                     error);
        }
        else
        {
            if (IPAddresses.count > 1)
            {
                DebugLog(@"PROGRAMMING ERROR: more then one IPAddress marked as selected");
            }
            for (JRTIPAddress * anIPAddress in IPAddresses)
            {
                anIPAddress.isSelected = @(NO);
            }

            NSError * saveError = nil;

            if (self.privateQueueContext.hasChanges)
            {
                if (![self.privateQueueContext persistError: &saveError])
                {
                    DebugLog(@"ERROR: could not persist privateQueueContext in %@: %@",
                             NSStringFromClass([self class]),
                             saveError);
                }
            }

            [IPAddress.managedObjectContext performBlock:^{
                IPAddress.isSelected = @(YES);
                NSError * mainSaveError = nil;
                if (IPAddress.managedObjectContext.hasChanges)
                {
                    if (![IPAddress.managedObjectContext persistError: &mainSaveError])
                    {
                        DebugLog(@"ERROR: could not persist mainQueueContext in %@: %@",
                                 NSStringFromClass([self class]),
                                 mainSaveError);
                    }
                }
            }];
        }
    }];
}
- (JRTIPAddress *) selectedIPAddressMainQueueContext
{
    NSFetchRequest * fetchForIPAddress;
    fetchForIPAddress = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass([JRTIPAddress class])];
    fetchForIPAddress.predicate = [NSPredicate predicateWithFormat: @"isSelected == %@",
                                   @(YES)];
    JRTIPAddress __block * selectedIPAddress = nil;
    [self.mainQueueContext performBlockAndWait:^{
        NSError * error = nil;
        NSArray * IPAddresses;
        IPAddresses = [self.mainQueueContext executeFetchRequest: fetchForIPAddress

                                                           error: &error];
        if (nil == IPAddresses)
        {
            DebugLog(@"ERROR executing fetchreqeust in %@: %@",
                     NSStringFromClass([self class]),
                     error);
        }
        else
        {
            if (IPAddresses.count > 1)
            {
                DebugLog(@"PROGRAMMING ERROR: more then one IPAddress marked as selected");
            }
            selectedIPAddress = [IPAddresses lastObject];
        }
    }];
    return selectedIPAddress;
}
@end
