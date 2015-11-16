//
//  JRTH264VideoStreamProcessor.m
//  PiView
//
//  Created by Joride on 09-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "JRTH264VideoStreamProcessor.h"
#import "NSData+NALUnit.h"

typedef void(^SampleHandler)(CMSampleBufferRef sampleBuffer);

@interface JRTH264VideoStreamProcessor ()
@property (nonatomic, strong) SampleHandler sampleHandler;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation JRTH264VideoStreamProcessor
{
    NSMutableData * _currentNALunit;
    uint8_t * _remainingBytesFromPreviousStreamCallBack;
    NSInteger _remainingBytesCountFromPreviousStreamCallBack;
    uint8_t * _NALPictureParameterSet;
    NSInteger _NALPictureParameterSetLength;
    uint8_t * _NALSequenceParameterSet;
    NSInteger _NALSequenceParameterSetLength;
    NSInteger _frameCount;
    CMSampleTimingInfo * _timingInfo;
}

-(instancetype)initWithSampleHandler: (void(^)(CMSampleBufferRef sampleBuffer)) sampleHandler
                         handleQueue: (dispatch_queue_t) queue
{
    NSParameterAssert(sampleHandler);
    NSParameterAssert(queue);

    self = [super init];
    if (self)
    {
        _sampleHandler = sampleHandler;
        _queue = queue;
        [self setup];
    }
    return self;
}
- (void) setup
{
    CMSampleTimingInfo timingInfo =
    {
        .presentationTimeStamp = CMTimeMake(1, 120),
        .duration =  CMTimeMake(1, 120),
        .decodeTimeStamp = kCMTimeInvalid
    };
    _timingInfo = malloc(sizeof(CMSampleTimingInfo));
    _timingInfo[0] = timingInfo;

}
- (void) processBytesFromStream: (NSInputStream *) inputStream
{
    while (inputStream.hasBytesAvailable)
    {
        NSUInteger numberOfBytesToRead = 4096;
        NSAssert(numberOfBytesToRead > 4,
                 @"The number of bytes to be read MUST be greater then 4. Ideally it is about between one and two times the size of a NAL unit");
        uint8_t * bytes = malloc(sizeof(uint8_t) * numberOfBytesToRead);
        NSInteger numberOfBytesRead = [inputStream read: bytes
                                              maxLength: numberOfBytesToRead];

        // operation failed, we have no bytes to process
        if (numberOfBytesRead == -1)
        {
            free(bytes);
            continue;
        }

        if (_remainingBytesFromPreviousStreamCallBack != NULL)
        {
            NSInteger extendedBytesSize = numberOfBytesRead + _remainingBytesCountFromPreviousStreamCallBack;
            uint8_t * extendedBytes = malloc(sizeof(uint8_t) * extendedBytesSize);

            // copy the left-over bytes from a previous iteration or callback
            // into the extended array
            memcpy(extendedBytes,
                   _remainingBytesFromPreviousStreamCallBack,
                   sizeof(uint8_t) * _remainingBytesCountFromPreviousStreamCallBack);

            // copy the freshly read bytes into the extended array
            memcpy(&extendedBytes[_remainingBytesCountFromPreviousStreamCallBack],
                   bytes,
                   sizeof(uint8_t) * numberOfBytesRead);

            // update the numberOfBytesRead to include the leftoverbytes
            numberOfBytesRead += _remainingBytesCountFromPreviousStreamCallBack;

            // reset and clear these values
            free(_remainingBytesFromPreviousStreamCallBack);
            _remainingBytesFromPreviousStreamCallBack = NULL;
            _remainingBytesCountFromPreviousStreamCallBack = 0;

            // free the originally allocated array
            free(bytes);

            // re-assign the pointer (this will be freed later, as if this
            // conditional never happened
            bytes = extendedBytes;
        }

        if (numberOfBytesRead < 0)
        {
            DebugLog(@"ERROR: reading bytes failed");
            NSAssert(NO, @"restart the stream");
        }
        else if (numberOfBytesRead > 0)
        {
            // the CreateNALStartIndexesFromBuffer() function does not accept
            // buffers shorter then 4 bytes long. So when we are left with
            // less then 4 bytes, we save them to prepend to the next incoming
            // stream.
            if (numberOfBytesRead < 4)
            {
                _remainingBytesFromPreviousStreamCallBack = malloc(numberOfBytesRead * sizeof(uint8_t));
                memcpy(_remainingBytesFromPreviousStreamCallBack,
                       bytes,
                       sizeof(uint8_t) * numberOfBytesRead);
                _remainingBytesCountFromPreviousStreamCallBack = numberOfBytesRead;

            }
            else
            {
                NSUInteger numberOfIndexes = 0;
                NSUInteger * startCodonIndexes =  CreateNALStartIndexesFromBuffer(bytes,
                                                                                  numberOfBytesRead,
                                                                                  &numberOfIndexes);
                /*
                 1: x x x x x x x x x x x x x(0 0) | (0 1 x x x x)
                 2: x x x x x 0 0 0 1 x x x x(x x x x x x x x 0 0 0 1 x x x x x)
                 3: x x x x x x x x x x x x x x x 0 0 0 1 x x x x x

                 1. if we have zero indexes, there might be part of a startcodon
                 at the end. We can only know if there really is one,once the
                 next part comes in. Therefore we retain that part of the
                 bytes-buffer for the next run (and we do not blindly add it
                 to the currently being built NALU).
                 2. if we have at least one index, we append the bytes up to that
                 index to the currently being built NAL-unit, and we finalize
                 that NALU. For each subsequent index we create a new NALU
                 with the bytes between the previous and subsequent index.
                 3. we always set aside the bytes starting from the last index
                 to the last byte.
                 1 2 3 4 5 6 7 8 9
                 x x x x x x x x x
                 |
                 */
                if (numberOfIndexes == 0)
                {
                    // 1.
                    _remainingBytesFromPreviousStreamCallBack = malloc(numberOfBytesRead * sizeof(uint8_t));
                    memcpy(_remainingBytesFromPreviousStreamCallBack,
                           bytes,
                           sizeof(uint8_t) * numberOfBytesRead);
                    _remainingBytesCountFromPreviousStreamCallBack = numberOfBytesRead;
                }
                else if (numberOfIndexes > 0)
                {
                    for (NSUInteger index = 0; index < numberOfIndexes; index++)
                    {
                        if (index == (numberOfIndexes -1))
                        {
                            // 3.
                            // this is the last index, we save all bytes from
                            // that index to the last one for the next iteration
                            NSInteger startIndex = startCodonIndexes[index];
                            NSInteger numberOfBytesToSetAside = numberOfBytesRead - startIndex;

                            _remainingBytesFromPreviousStreamCallBack = malloc(numberOfBytesToSetAside * sizeof(uint8_t));
                            memcpy(_remainingBytesFromPreviousStreamCallBack,
                                   &bytes[startIndex],
                                   sizeof(uint8_t) * numberOfBytesToSetAside);
                            _remainingBytesCountFromPreviousStreamCallBack = numberOfBytesToSetAside;
                        }
                        else
                        {
                            // 2.
                            // there is an index after this one, so the bytes
                            // from the previous start up to this one can be
                            // saved into a new NAL

                            NSInteger thisIndex = startCodonIndexes[index];
                            NSInteger nextIndex = startCodonIndexes[index + 1];
                            NSInteger sizeOfNALU = nextIndex - thisIndex;
                            uint8_t * newNALU = malloc(sizeof(uint8_t) * sizeOfNALU);
                            memcpy(newNALU,
                                   &bytes[thisIndex],
                                   sizeof(uint8_t) * sizeOfNALU);
                            [self handleNALUnitBytes: newNALU
                                              length: sizeOfNALU];
                        }
                    }
                }
                free(startCodonIndexes);
            }
        }
        free(bytes);
    }
}
- (void) handleNALUnitBytes: (uint8_t *) NALBytes
                     length: (NSInteger) totalLength
{
    NSAssert(totalLength > 3,
             @"NALBytes have to be at least 4 bytes: startcodon (minimum 3, but usually 4) + at leat one actual content byte");

    if (NALBytesHasFourByteStartCodon(NALBytes))
    {
        ReplaceNALStartCodonInBufferWithLength(NALBytes,
                                               totalLength - 4);
    }
    else if (NALBytesHasThreeByteStartCodon(NALBytes))
    {
        // we have to add an extra byte to the beginning of the array
        NSInteger newLength = totalLength + 1;
        uint8_t * extendedNALBytes = malloc(sizeof(uint8_t) * (newLength));
        memcpy(&extendedNALBytes[1],
               NALBytes,
               totalLength);
        ReplaceNALStartCodonInBufferWithLength(extendedNALBytes, newLength - 4);
        free(NALBytes);
        NALBytes = extendedNALBytes;
        totalLength = totalLength + newLength;
    }
    else
    {
        NSAssert(NO, @"INVALID NALBuffer: These NALBytes have no startCodon");
    }
    [self feedDisplayLayerConvertedNALUnit: NALBytes
                                    length: totalLength];
}
- (void) feedDisplayLayerConvertedNALUnit: (uint8_t *) bytes
                                   length: (NSInteger) length
{
    NALType type = NALTypeFromMPEG4Bytes(bytes);
    if (type == kNALTypePictureParameterSet)
    {
        if (_NALPictureParameterSet != NULL)
        {
            free(_NALPictureParameterSet);
        }
        _NALPictureParameterSet = bytes;
        _NALPictureParameterSetLength = length;
    }
    else if (type == kNALTypeSequenceParameterSet)
    {
        if (_NALSequenceParameterSet != NULL)
        {
            free(_NALSequenceParameterSet);
        }
        _NALSequenceParameterSet = bytes;
        _NALSequenceParameterSetLength = length;
    }
    else if (_NALPictureParameterSet != NULL &&
             _NALSequenceParameterSet != NULL)
    {
        const uint8_t* const parameterSetPointers[2] =
        {
            (const uint8_t*) &_NALPictureParameterSet[4],
            (const uint8_t*) &_NALSequenceParameterSet[4]
        };

        const size_t parameterSetSizes[2] =
        {
            (size_t)_NALPictureParameterSetLength - 4,
            (size_t)_NALSequenceParameterSetLength - 4
        };
        CMFormatDescriptionRef formatDescription;
        OSStatus formDescReult;
        formDescReult =
        CMVideoFormatDescriptionCreateFromH264ParameterSets(NULL,
                                                            2,
                                                            parameterSetPointers,
                                                            parameterSetSizes,
                                                            4,
                                                            &formatDescription);
        if (formDescReult != 0)
        {
            DebugLog(@"formatDescription problem");
            return;
        }

        CMBlockBufferRef blockBuffer;
        OSStatus bBufResult;
        bBufResult =
        CMBlockBufferCreateWithMemoryBlock(NULL,
                                           bytes, // If non-NULL, the block will be used and will be deallocated when the new CMBlockBuffer is finalized (i.e. released for the last time).
                                           length,
                                           NULL,
                                           NULL,
                                           0,
                                           length,
                                           0,
                                           &blockBuffer); //Receives newly-created CMBlockBuffer object with a retain count of 1. Must not be  NULL.
        if (bBufResult != 0)
        {
            DebugLog(@"blockBufferResult problem");
            return;
        }

        uint64_t count = (uint64_t) _frameCount;
        CMSampleTimingInfo timingInfo =
        {
            .presentationTimeStamp = CMTimeMake(count, 120),
            .duration =  CMTimeMake(1, 120),
            .decodeTimeStamp = kCMTimeInvalid
        };
        _timingInfo[0] = timingInfo;
        _frameCount++;

        CMSampleBufferRef sampleBuffer;
        // On return, the caller owns the returned CMSampleBuffer, and must release it when done with it.
        OSStatus sampleBufferResult =
        CMSampleBufferCreate(NULL,
                             blockBuffer,
                             YES, // If CMBlockBuffer contains the media data, dataReady should be true.
                             NULL,
                             NULL,
                             formatDescription,
                             1,
                             1,
                             _timingInfo,
                             0,
                             NULL,
                             &sampleBuffer); // On return, the caller owns the returned CMSampleBuffer, and must release it when done with it.
        if (sampleBufferResult != 0)
        {
            DebugLog(@"sampleBufferResult problem");
            return;

        }

        dispatch_async(self.queue, ^{
            self.sampleHandler(sampleBuffer);
            CFRelease(formatDescription);
            CFRelease(blockBuffer);
            CFRelease(sampleBuffer);

//             free(bytes);
            // CMBlockBufferCreateWithMemoryBlock releases these bytes
            // once CFRelease is called with the CMBlockBufferRef as arg.
        });
    }
}
-(void)dealloc
{
    if (_remainingBytesFromPreviousStreamCallBack != NULL)
    {
        free(_remainingBytesFromPreviousStreamCallBack);
        _remainingBytesFromPreviousStreamCallBack = NULL;
    }
    if (_timingInfo != NULL)
    {
        free(_timingInfo);
        _timingInfo = NULL;
    }
}

@end
