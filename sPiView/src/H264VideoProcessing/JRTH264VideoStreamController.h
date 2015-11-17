//
//  JRTVideoStreamController.h
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

@import Foundation;
@import QuartzCore;

/*!
 @class JRTVideoStreamController : NSObject
 This class performs all the neccessary work to setup a stream, have the stream
 interpreted and forward it to a system-provided CALayer-subclass.
 Internally, a socket is setup to get an incoming stream of byutes, and a 
 H264-stream processor are used to pre-process the incoming data. The 
 pre-processed data is then forwarded to a system CALayer which can display the
 video. These dependecies are as of yet hardcoded into the processor, but
 up for being configurable.
 */
@interface JRTH264VideoStreamController : NSObject

/*!
 @property CALayer * sampleBufferDisplayLayer
 A CALayer that displays the videao that is returned from a connection.
 */
@property (nonatomic, readonly) CALayer * sampleBufferDisplayLayer;

/*!
 @method - (void) startStream
 This method starts a stream. This stream is internally setup using a helper,
 and can be configured there.
 */
- (void) startStream;

/*!
 @method - (void) stopStream
 This method stops a stream.
 */
- (void) stopStream;

/*!
 @method - (instancetype) initWithIPAddress: (NSString *) IPAddress
 This is the designated initializer of this class
 @param IPAddress
 An IP address to connect to.
 @return JRTVideoStreamController
 A fully initialized JRTVideoStreamController;
 */
- (instancetype) initWithIPAddress: (NSString *) IPAddress
NS_DESIGNATED_INITIALIZER;

/*!
 @property NSString * IPAddress
 This property returns a copy of the IP address that the receiver was 
 initialized with.
 */
@property (nonatomic, copy, readonly) NSString * IPAddress;

-(instancetype)init NS_UNAVAILABLE;

@end
