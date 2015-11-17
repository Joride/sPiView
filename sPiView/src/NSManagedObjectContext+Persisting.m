//
//  NSManagedObjectContext+Persisting.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "NSManagedObjectContext+Persisting.h"

@implementation NSManagedObjectContext (Persisting)
- (BOOL) persistError: (inout NSError **) error
{
    BOOL __block success = NO;

    NSManagedObjectContext __block  *context = self;
    while (nil != context)
    {
        [self performBlockAndWait:^{
            success = [context save: error];
            context = context.parentContext;
        }];
    }

    return success;
}
@end
