//
//  NSFileManager+ApplicationDirectories.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import Foundation;

@interface NSFileManager (ApplicationDirectories)
- (NSURL *) applicationSupportURLError: (inout NSError **) outError;
@end
