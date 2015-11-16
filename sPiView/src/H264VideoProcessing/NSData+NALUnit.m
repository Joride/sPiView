//
//  NSData+NALUnit.m
//  SaveStream
//
//  Created by Joride on 01-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "NSData+NALUnit.h"

NSUInteger *  CreateNALStartIndexesFromBuffer(uint8_t * buffer,
                                              NSUInteger bufferLength,
                                              NSUInteger * numberOfIndexes)
{
    assert(bufferLength > 3);

    // starting size of the buffer
    NSUInteger lengthOfIndexBuffer = 8;

    // the buffer will be reallocated with a double
    // size each time this is neccessary
    NSUInteger * indexesArray = malloc(sizeof(NSUInteger) * lengthOfIndexBuffer);

    NSUInteger numberOfFoundIndexes = 0;
    NSUInteger searchIndex = 0;
    while (searchIndex < (bufferLength - 3))
    {
        NSInteger indexOffset = 1;
        if ((buffer[searchIndex]     == 0x00) &&
            (buffer[searchIndex + 1] == 0x00) &&
            (buffer[searchIndex + 2] == 0x00) &&
            (buffer[searchIndex + 3] == 0x01))
        {
            // skip the startCodon next itaration
            indexOffset = 4;
        }
        else if ((buffer[searchIndex]     == 0x00) &&
                 (buffer[searchIndex + 1] == 0x00) &&
                 (buffer[searchIndex + 2] == 0x01))
        {
            // skip the startCodon next itaration
            indexOffset = 3;
        }

        if (indexOffset != 1)
        {
            // we found a startCodon at this index.
            // we store it in the outArray
            if (searchIndex >= lengthOfIndexBuffer)
            {
                lengthOfIndexBuffer *= 2;
                NSUInteger * reallocated = realloc(indexesArray,
                                                   sizeof(NSUInteger) * lengthOfIndexBuffer);
                if (reallocated == NULL)
                {
                    // could not allocate this memory
                    assert(NO);
                }
                else
                {
                    indexesArray = reallocated;
                }
            }
            indexesArray[numberOfFoundIndexes] = searchIndex;
            numberOfFoundIndexes++;
        }
        // update the searchIndex
        searchIndex += indexOffset;
    }
    *numberOfIndexes = numberOfFoundIndexes;
    return indexesArray;
}

NSString * BytesInBufferAsString(uint8_t * buffer, NSUInteger length)
{
    NSMutableString * bytesString = [[NSMutableString alloc] initWithString: @""];
    for (NSUInteger index = 0; index < length; index++)
    {
        {
            if ((index) % 4 == 0 && index != 0)
            {
                [bytesString appendFormat: @"\t"];
            }
            if ((index + 1) % 4 == 0 && index != 0)
            {
                [bytesString appendFormat: @"%02x", buffer[index]];
            }
            else if ((index) % 4 == 0)
            {
                if (index == 0)
                {
                    [bytesString appendFormat: @"%04li\t%02x-", (long)index, buffer[index]];
                }
                else
                {
                    [bytesString appendFormat: @"\n%04li\t%02x-", (long)index, buffer[index]];
                }
            }
            else
            {
                [bytesString appendFormat: @"%02x-", buffer[index]];
            }
        }
    }
    return bytesString;
}
void ReplaceNALStartCodonInBufferWithLength(uint8_t * buffer,
                                            NSUInteger lengthToReplaceStartCodonWith)
{
    // sizeof(NSUInteger) = 4 on iPhone 5 and below, 8 on iPhone 5S
    buffer[3] = (lengthToReplaceStartCodonWith >> 0) & 0b11111111;
    buffer[2] = (lengthToReplaceStartCodonWith >> 8) & 0b11111111;
    buffer[1] = (lengthToReplaceStartCodonWith >> 16) & 0b11111111;
    buffer[0] = (lengthToReplaceStartCodonWith >> 24) & 0b11111111;
}
BOOL NALBytesHasFourByteStartCodon(uint8_t * buffer)
{
    return ((buffer[2] == 0x00) &&
            (buffer[3] == 0x01));
}
BOOL NALBytesHasThreeByteStartCodon(uint8_t * buffer)
{
    return ((buffer[1] == 0x00) &&
            (buffer[2] == 0x01));
}
NALType NALTypeFromBytes(uint8_t * bytes)
{
    uint8_t returnValue = 0;
    if (NALBytesHasFourByteStartCodon(bytes))
    {
        returnValue = bytes[4] & 0b00011111; // the first three bits do not contain information
    }
    else if (NALBytesHasThreeByteStartCodon(bytes))
    {
        returnValue = bytes[4]  & 0b00011111; // the first three bits do not contain information
    }
    else
    {
        // the bytes MUST have a valid startcodon
        assert(NO);
    }
    return (NALType)returnValue;
}
NALType NALTypeFromMPEG4Bytes(uint8_t * bytes)
{
    uint8_t returnValue = 0;
    returnValue = bytes[4] & 0b00011111; // the first three bits do not contain information
    return (NALType)returnValue;

}



@implementation NSData (NALUnit)
- (NSData *) dataByReplacingNALStartCodonWithNALContentLength
{
    NSUInteger allBytes = self.length;
    uint8_t * bytes = malloc(allBytes * sizeof(uint8_t));
    [self getBytes: bytes
            length: allBytes];
    ReplaceNALStartCodonInBufferWithLength(bytes, allBytes-4);
    NSData * returnValue = [NSData dataWithBytes: bytes
                                          length: allBytes];
    free(bytes);
    return returnValue;
}
- (NSString *) bytesAsString
{
    NSUInteger length = [self length];
    uint8_t * bytes = malloc(sizeof(uint8_t) * length);
    [self getBytes: bytes
            length: length];

    NSString * bytesAsString = BytesInBufferAsString(bytes, length);
    free(bytes);
    return bytesAsString;
}
-(NALType)NALType
{
    uint8_t returnValue = 0;
    uint8_t * bytes = malloc(sizeof(uint8_t) * 5);
    [self getBytes: bytes
            length: 5];
    returnValue = NALTypeFromBytes(bytes);
    free(bytes);
    return returnValue;
}

@end
