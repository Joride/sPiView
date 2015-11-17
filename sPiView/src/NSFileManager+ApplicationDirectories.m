//
//  NSFileManager+ApplicationDirectories.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "NSFileManager+ApplicationDirectories.h"

@implementation NSFileManager (ApplicationDirectories)
- (NSURL *) applicationSupportURLError: (inout NSError **) outError
{
    NSError * error = nil;
    NSURL * appSupportDirectoryURL = [self URLForDirectory: NSApplicationSupportDirectory
                                                  inDomain: NSUserDomainMask
                                         appropriateForURL: nil
                                                    create: YES
                                                     error: &error];
    if (nil != error)
    {
        if (NULL != outError)
        {
            * outError = error;
            appSupportDirectoryURL = nil;
        }
    }

    return appSupportDirectoryURL;
}
@end
