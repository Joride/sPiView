//
//  JRTSocket.h
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

@import Foundation;

@class JRTSocket;
@protocol JRTSocketReceiver <NSObject>
/*!
 @method -(void)socket:(JRTSocket *) socket didReceiveDataInStream:(NSInputStream *) inputStream;
 This method is called when there are bytes available in the stream.
 @param socket
 The JRTSocket that read the bytes
 @param bytes
 A pointer to an array of uint8_t. After this method is called, the receiver is
 the owner of these bytes, and is responsible for calling free() on the pointer.
 @param inputStream
 An NSInputStream that has bytes available to read
 */
- (void) socket: (JRTSocket *) socket
didReceiveDataInStream: (NSInputStream *) inputStream;

/*!
 @method - (void) socketClosed:(JRTSocket *)socket
 @param socket
 The JRTSocket that was closed.- (void) socketClosed:(JRTSocket *)socket;
 */
- (void) socketClosed:(JRTSocket *)socket;
@end


@interface JRTSocket : NSObject

/*!
 @method -(void)setReadBlockSize:(NSUInteger)readBlockSize
 This method will set the size of the blocks that are being read from the
 stream.
 @param readBlockSize
 The maximum size of the block of bytes that gets read from the stream and delivered to
 the delegate. Defaults is 4096
 @discussion
 When bytes are read from the stream, memory is allocated ot hold the bytes in
 blocks of readBlockSize chunks. When value is set to smaller values, less
 unused memory will be alloced, but possibly more allocations are performed. In
 addition, when this values is small, the callbackes to the receiver property
 migh be more frequent.
 @note
 The optimal value can only be determined on a case-by-case basis. It depends
 on various factors, like server-side implementation, bandwidth of the network,
 amount of data to be transferred, client-side processing of the bytes.
 */
- (void) setReadBlockSize:(NSUInteger)readBlockSize;

/*!
 @method -(instancetype)initWithHost:(NSString *)hostAddress portNumber:(NSNumber *)portNumber callbackQueue:(dispatch_queue_t) callbackQueue
 This method is the designated initializer of JRTSocket
 @param hostAddress
 The IP-adress of domain name of the host. Cannot be nil;
 @param portNumber
 The portnumber to be used for the connection. Cannot be nil;
 @param callbackQueue
 A queue to be used for calling the receiver property. Cannot be NULL.
 */
- (instancetype) initWithHost: (NSString *) hostAddress
                   portNumber: (NSNumber *) portNumber
                     receiver: (id<JRTSocketReceiver>) receiver
                callbackQueue: (dispatch_queue_t) callbackQueue
NS_DESIGNATED_INITIALIZER;

/*!
 @method -(BOOL)writeBytes:(uint8_t *)bytes length:(NSInteger)length
 Tries to write the given bytes into the socket.
 @param bytes
 The bytes to write. The socket will not own these bytes, and not call free()
 on the pointer.
 @param length
 The lenfth if the bytes-array
 @return YES if all bytes were succesfully written to the socket. No if there
 was an error or not all bytes were written.
 */
- (BOOL) writeBytes: (uint8_t *) bytes
             length: (NSInteger) length;

- (void) close;


@end
