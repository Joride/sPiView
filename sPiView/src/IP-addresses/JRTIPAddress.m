//
//  JRTIPAddress.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTIPAddress.h"

@implementation JRTIPAddress
+ (JRTIPAddress *) newIPAddressInManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSEntityDescription * description = [NSEntityDescription entityForName: @"JRTIPAddress"
                                                    inManagedObjectContext:managedObjectContext];
    JRTIPAddress * newIPAddress = [[JRTIPAddress alloc] initWithEntity: description
                                        insertIntoManagedObjectContext: managedObjectContext];
    return newIPAddress;
}
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.modificationDate = [NSDate date];
}
-(void)willSave
{
    if (!self.deleted &&
        self.hasChanges)
    {
        NSTimeInterval minimumTimeInterval = 5;
        if (ABS([self.modificationDate timeIntervalSinceNow]) > minimumTimeInterval)
        {
            self.modificationDate = [NSDate date];
        }
    }
}
@end
