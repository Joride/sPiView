//
//  JRTDebug+JRTDebug.h
//
//  Created by Joride on 16/11/15.
//  Copyright (c) 2014 KerrelInc. All rights reserved.

@import Foundation;

/*!
 void inline ObjCDebugLog(NSString *format)
 This method logs a message to the system console when the Objective-C pre-
 processor macro DEBUG is defined to a non-zero value. Othwerwise it does
 nothing.
 @param format
 An NSString to log to the console.
 @note This function exists because the print() function of Swift does not
 print to the system consolse. This function will, and so also outside of a 
 session attached to debugger, this function will log to the console.
 */
void inline ObjCDebugLog(NSString *format);

/*!
 @function void inline ObjCLog(NSString *format);
 This method is identical to the SwiftDebugLog function, except that it always
 logs to the console, regardless of pre-processor flags. It is a wrapper around
 DebugLog, but this one has an easier syntax in Swift: 
    aObjCLog("A string with a variable: \(someVariable)")
 */
void inline ObjCLog(NSString *format);
