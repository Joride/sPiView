//
//  JRTSocket.m
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "JRTSocket.h"

const char * kJRTSocketQueueName =  "com.kerrelinc.JRTSocket";

@interface JRTSocket () <NSStreamDelegate>
@property (nonatomic, weak) id<JRTSocketReceiver> receiver;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSNumber * port;
@property (nonatomic, strong) NSInputStream * inputStream;
@property (nonatomic, strong) NSOutputStream * outputStream;
@property (nonatomic, strong) NSThread * thread;
@property (nonatomic) NSUInteger readBlockSize;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, readonly) dispatch_queue_t callbackQueue;
@end

@implementation JRTSocket
{
    BOOL _writeSuccesfull;
    uint8_t * _bytesToWrite;
    NSInteger _numberOfBytesToWrite;
}
-(void)close
{
    NSAssert(NO, @"Not implemented");
    /*
     Closing the Connection
     To close your connection, unschedule it from the run loop, set the connection’s delegate to nil (the delegate is unretained), close both of the associated streams with the close method, and then release the streams themselves (if you are not using ARC) or set them to nil (if you are). By default, this closes the underlying socket connection. There are two situations in which you must close it yourself, however:

     If you previously set the kCFStreamPropertyShouldCloseNativeSocket to kCFBooleanFalse by calling setProperty:forKey: on the stream.
     If you created the streams based on an existing BSD socket by calling CFStreamCreatePairWithSocket.
     By default, streams created from an existing native socket do not close their underlying socket. However, you can enable automatic closing by setting the kCFStreamPropertyShouldCloseNativeSocket to kCFBooleanTrue with the setProperty:forKey: method.
     

     */
}
- (void) setReadBlockSize:(NSUInteger)readBlockSize
{
    [self performSelector: @selector(_setReadBlockSize:)
                 onThread: self.thread
               withObject: @(readBlockSize)
            waitUntilDone: NO];
}
- (void) _setReadBlockSize:(NSNumber *) readBlockSize
{
    _readBlockSize = readBlockSize.unsignedIntegerValue;
}
- (instancetype) initWithHost: (NSString *) hostAddress
                   portNumber: (NSNumber *) portNumber
                     receiver: (id<JRTSocketReceiver>) receiver
                callbackQueue: (dispatch_queue_t) callbackQueue
{
    self = [super init];

    if (self)
    {
        _receiver = receiver;
        _callbackQueue = callbackQueue;
        _readBlockSize = 1 << 12; // default is 4096
        _queue = dispatch_queue_create(kJRTSocketQueueName,
                                       DISPATCH_QUEUE_SERIAL);
        _host = hostAddress;
        _port = portNumber;
        _thread = [[NSThread alloc]
                   initWithTarget:self
                   selector:@selector(initializeSocket:)
                   object:nil];
        _thread.name = NSStringFromClass([self class]);

        [_thread start];
    }
    return self;
}
- (void) initializeSocket: (id) sender
{

    //    @autoreleasepool
    //    {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    uint32_t portNumber = (uint32_t) self.port.intValue;
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)self.host,
                                       portNumber,
                                       &readStream,
                                       &writeStream);
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;

    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];

    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [_inputStream scheduleInRunLoop: runLoop
                            forMode: NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop: runLoop
                             forMode: NSDefaultRunLoopMode];

    [_inputStream open];
    [_outputStream open];
    [[NSRunLoop currentRunLoop] run];
    //    }
}
#pragma mark - NSStreamDelegate
- (void)stream: (NSStream *)theStream
   handleEvent: (NSStreamEvent)streamEvent
{
    [self processStream: theStream
            handleEvent: streamEvent];
}

#pragma mark - Stream Handling
- (void) processStream: (NSStream *) theStream
           handleEvent: (NSStreamEvent) streamEvent
{
    id <JRTSocketReceiver> receiver = self.receiver;
    switch (streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
            
            if ([receiver respondsToSelector: @selector(socket:didReceiveDataInStream:)])
            {
                dispatch_async(self.callbackQueue, ^{
                    [receiver socket: self
              didReceiveDataInStream: (NSInputStream *) theStream];
                });
            }
            break;
        case NSStreamEventEndEncountered:
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            // called when the connection is established
            if ([receiver respondsToSelector:@selector(socketOpened:)])
            {
                [receiver socketOpened: self];
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventErrorOccurred:
            [theStream close];
            if ([receiver respondsToSelector:@selector(socketClosed:)])
            {
                [receiver socketClosed: self];
            }
            break;
        default:
            ;
            break;
    }

}
#pragma mark -
-(BOOL)writeBytes:(uint8_t *)bytes
           length:(NSInteger)length
{
    if (bytes == NULL || length == 0)
    {
        return NO;
    }
    __block BOOL success = NO;
    dispatch_sync(self.queue, ^{
        self->_bytesToWrite = bytes;
        self->_numberOfBytesToWrite = length;
        [self performSelector: @selector(_writeBytes)
                     onThread: self.thread
                   withObject: nil
                waitUntilDone: YES];
        success = self->_writeSuccesfull;
    });
    return success;
}

#pragma mark -
- (void) _writeBytes
{
    _writeSuccesfull = NO;
    NSInteger bytesWritten = [self.outputStream write: _bytesToWrite
                                            maxLength: _numberOfBytesToWrite];
    _writeSuccesfull = (bytesWritten == _numberOfBytesToWrite);
}
@end












