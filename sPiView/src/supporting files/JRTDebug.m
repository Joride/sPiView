//
//  JRTDebug+JRTDebug.h
//
//  Created by Joride on 16/11/15.
//  Copyright (c) 2014 KerrelInc. All rights reserved.

#import "JRTDebug.h"

void ObjCDebugLog(NSString *format)
{
    DebugLog(@"%@", format);
}
void ObjCLog(NSString *format)
{
    NSLog(@"%@", format);
}