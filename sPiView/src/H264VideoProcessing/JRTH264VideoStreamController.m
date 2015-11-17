//
//  JRTVideoStreamController.m
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "JRTH264VideoStreamController.h"
#import "JRTSocket.h"
#import "JRTH264VideoStreamProcessor.h"
@import AVFoundation;

const char * kJRTVideoStreamControllerQueue = "com.kerrelinc.JRTVideoStreamController";

@interface JRTH264VideoStreamController () <JRTSocketReceiver>
@property (nonatomic, readonly) JRTSocket * socket;
@property (nonatomic, readonly) JRTH264VideoStreamProcessor * videoStreamProcessor;
@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, strong) AVSampleBufferDisplayLayer * sampleBufferDisplayLayer;
@property (nonatomic, copy) NSString * IPAddress;
@end

@implementation JRTH264VideoStreamController

#pragma mark - Public
- (instancetype) initWithIPAddress: (NSString *) IPAddress
{
    NSParameterAssert(IPAddress);
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create(kJRTVideoStreamControllerQueue,
                                       DISPATCH_QUEUE_SERIAL);
        _IPAddress = [IPAddress copy];
    }
    return self;
}
- (CALayer *) sampleBufferDisplayLayer
{
    if (nil == _sampleBufferDisplayLayer)
    {
        AVSampleBufferDisplayLayer * displayLayer = nil;
        displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
        displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        CMTimebaseRef timebase;
        OSStatus timebaseResult;
        timebaseResult = CMTimebaseCreateWithMasterClock(NULL,
                                                         CMClockGetHostTimeClock(),
                                                         &timebase);
        if (timebaseResult != 0)
        {
            DebugLog(@"ERROR: could not create time base");
        }
        else
        {
            CMTimebaseSetTime(timebase,
                              CMTimeMake(0, 600));
            CMTimebaseSetRate(timebase,
                              1.0f); // keep the rate the same as the masterclock
        }
        displayLayer.controlTimebase = timebase;
        NSNotificationCenter * notificationCenter;
        notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver: self
                               selector: @selector(sampleBufferDisplayLayerFailedToDecodeNotification:)
                                   name: AVSampleBufferDisplayLayerFailedToDecodeNotification
                                 object: nil];
        _sampleBufferDisplayLayer = displayLayer;
    }
    return _sampleBufferDisplayLayer;
}
- (void) sampleBufferDisplayLayerFailedToDecodeNotification: (NSNotification *) notification
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        DebugLog(@"%@", notification.userInfo[AVSampleBufferDisplayLayerFailedToDecodeNotificationErrorKey]);
    });
}


const uint8_t kBeginOfMessage   = 0b10000000;
const uint8_t kEndOfMessage     = 0b11000000;

- (void) startStream
{
    uint8_t startBytes[3] =
    {
        kBeginOfMessage,
        0b00000001,
        kEndOfMessage
    };
    [self.socket writeBytes: startBytes
                     length: 3];
}
- (void) stopStream
{
    if (nil != _socket)
    {
        uint8_t startBytes[3] =
        {
            kBeginOfMessage,
            0b00000000,
            kEndOfMessage
        };
        [self.socket writeBytes: startBytes
                         length: 3];
    }
}

#pragma mark - JRTSocketReceiver
-(void)socket:(JRTSocket *)socket
didReceiveDataInStream:(NSInputStream *)inputStream
{
    [self.videoStreamProcessor processBytesFromStream: inputStream];
}
-(void)socketClosed:(JRTSocket *)socket
{
    _socket = nil;
}

#pragma mark - Accessors
@synthesize socket = _socket;
@synthesize videoStreamProcessor = _videoStreamProcessor;
-(JRTSocket *)socket
{
    if (nil == _socket)
    {
        NSNumber * port = @(82);
        NSAssert(nil != self.IPAddress, @"Expecting an IP address here");
        DebugLog(@"Initializing a socket on IP %@ at port %@",
                 self.IPAddress,
                 port);
        _socket = [[JRTSocket alloc] initWithHost: self.IPAddress
                                       portNumber: port
                                         receiver: self
                                    callbackQueue: self.queue];
    }
    return _socket;
}
-(JRTH264VideoStreamProcessor *)videoStreamProcessor
{
    if (_videoStreamProcessor == nil)
    {
        void(^sampleHandler)(CMSampleBufferRef);
        sampleHandler = ^(CMSampleBufferRef sampleBuffer)
        {
            if (nil != self.sampleBufferDisplayLayer.superlayer)
            {
                AVSampleBufferDisplayLayer * displayLayer;
                displayLayer = (AVSampleBufferDisplayLayer *) self.sampleBufferDisplayLayer;
                [displayLayer enqueueSampleBuffer: sampleBuffer];
                if (displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed)
                {
                    DebugLog(@"ERROR: %@", displayLayer.error);
                    return;
                }
                else
                {
                    // DebugLog(@"STATUS: %i", (int)_displayLayer.status);
                }
            }
        };

        _videoStreamProcessor = [[JRTH264VideoStreamProcessor alloc]
                                     initWithSampleHandler: sampleHandler
                                     handleQueue: self.queue];
    }
    return _videoStreamProcessor;
}
@end
