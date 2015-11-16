//
//  JRTH264VideoStreamProcessor.h
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

@import Foundation;
@import CoreMedia;

/*!
 @class JRTH264VideoStreamProcessor : NSObject
 This class exists to handle an H.264 videostream that might come in in chunks.
 An instance of this class is intended to handle data from a single inputStream.
 Using multiple inputstreams will result in undefined behaviour.
 */
@interface JRTH264VideoStreamProcessor : NSObject

/*!
 @method -(instancetype)initWithSampleHandler: (void(^)(CMSampleBufferRef sampleBuffer)) sampleHandler handleQueue: (dispatch_queue_t) queue
 The designated initializer.
 @param queue
 A queu on which the sampleHandler will be called.
 Required.
 @param sampleHandler
 A block that gets fed CMSampleBufferRef items created from processed NAL-units
 originiating from the H.264 stream.
 Required.
 */
-(instancetype)initWithSampleHandler: (void(^)(CMSampleBufferRef sampleBuffer)) sampleHandler
                         handleQueue: (dispatch_queue_t) queue
NS_DESIGNATED_INITIALIZER;

/*!
 @method - (void) processBytesFromStream: (NSInputStream *) inputStream
 This method will take the available bytes from a stream and process it for
 NAL-units, which it will use to feed the sampleHandler.
 @param inputStream
 The stream is receiving H.264 video data.
 @note
 This method will save the bytes that could not yet be processed from the stream,
 and prepend them the next time this method is called.
 */
- (void) processBytesFromStream: (NSInputStream *) inputStream;

@end
