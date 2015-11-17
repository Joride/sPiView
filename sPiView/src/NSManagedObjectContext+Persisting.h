//
//  NSManagedObjectContext+Persisting.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import CoreData.NSManagedObjectContext;

@interface NSManagedObjectContext (Persisting)
- (BOOL) persistError: (inout NSError **) error;
@end
