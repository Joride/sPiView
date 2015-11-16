//
//  NSData+NALUnit.h
//  SaveStream
//
//  Created by Joride on 01-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

@import Foundation;

/*!
 @typedef uint8_t, NALType
 The abbreviation NAL stands for Network Abstraction Layer.
 The first byte of a NAL-packet is a header that contains information about the
 type of packet. All the possible packet types are in this enum.
 */
typedef NS_ENUM(uint8_t, NALType)
{
    kNALTypeCodedSliceOfNonIDRPicture = 0b00000001, // 1
    kNALTypeCodeSliceDataPartitionA = 0b00000010, // 2
    kNALTypeCodeSliceDataPartitionB = 0b00000011, // 3
    kNALTypeCodeSliceDataPartitionC = 0b00000100, // 4
    kNALTypeCodedSliceOfAnIDRPicture = 0b00000101, // 5
    kNALTypeSupplementalEnhancementInformation = 0b00000110, // 6 (a.ka. SEI)
    kNALTypeSequenceParameterSet = 0b00000111, // 7
    kNALTypePictureParameterSet = 0b00001000, // 8
    kNALTypeAccessUnitDelimiter = 0b00001001, // 9
    kNALTypeEndOfSequence = 0b00001010, // 10
    kNALTypeEndOfStream = 0b00001011, // 11
    kNALTypeFillerData = 0b00001100, // 12
    kNALTypeSequenceParameterSetExtension = 0b00001101, // 13
    kNALTypePrefixNALUnit = 0b00001110, // 14
    kNALTypeSubsetSequenceParameterSet = 0b00001111, // 15
    kNALTypeCodedSliceOfAuxiliaryCodedPictureWithoutPartitioning = 0b00010011, //19
    kNALTypeCodedSliceExtension = 0b00010100, // 20
    kNALTypeCodedSliceExtensionForDepthViewComponents = 0b00010101, // 21
};

/*!
 @function NSString * BytesInBufferAsString(uint8_t * buffer, NSUInteger length)
 This function converts a buffer of bytes into a string that is a hexadecimal
 representation of the bytes.
 @param buffer
 A pointer to the array of bytes.
 @param length
 The length of the buffer.
 */
NSString * BytesInBufferAsString(uint8_t * buffer, NSUInteger length);

/*!
 @function NSUInteger *  CreateNALStartIndexesFromBuffer(uint8_t * buffer, NSUInteger bufferLength, NSUInteger * numberOfIndexes)
 This function creates an array of NSUInteger that represent the start indexes
 of each NAL-unit start codon in the given buffer.
 @param buffer
 The buffer to be searched fro NAL-unit startcodons.
 @param bufferLength
 The length of the buffer.
 @param numberOfIndexes
 A pointer to an NSUInteger. Upon return it will contain the length of the 
 array pointed to by the return value.
 */
NSUInteger *  CreateNALStartIndexesFromBuffer(uint8_t * buffer,
                                              NSUInteger bufferLength,
                                              NSUInteger * numberOfIndexes);

/*!
 @function void ReplaceNALStartCodonInBufferWithLength(uint8_t * buffer, NSUInteger lengthToReplaceStartCodonWith)
 This function will encode the given lengthToReplaceStartCodonWith into four
 bytes and replace the first four bytes of buffer with these bytes.
 @param buffer
 The buffer of which the first four bytes will be replaced.
 @param lengthToReplaceStartCodonWith
 The length that will be encoded in four bytes.
 @warning The first four bytes of the given buffer are accessed without any
 assertions. The caller is responsible for owning the memory +3 bytes.
 */
void ReplaceNALStartCodonInBufferWithLength(uint8_t * buffer,
                                            NSUInteger lengthToReplaceStartCodonWith);

/*!
 @function NALType NALTypeFromBytes(uint8_t * bytes)
 This function will inspect a given buffer containing H.264 data and return a
 NALType for it.
 @param bytes
 A buffer of bytes form which to derive a NALType.
 @warning The argument must point to a memoryblock of five bytes long.
 */
NALType NALTypeFromBytes(uint8_t * bytes);

/*!
 @function NALType NALTypeFromMPEG4Bytes(uint8_t * bytes);
 This function will inspect a given buffer containing MPEG4-data and return a
 NALType for it.
 @param bytes
 A buffer of bytes form which to derive a NALType.
 @warning The argument must point to a memoryblock of five bytes long.
 */
NALType NALTypeFromMPEG4Bytes(uint8_t * bytes);

/*!
 @function BOOL NALBytesHasFourByteStartCodon(uint8_t * buffer)
 This method tells if the given buffer has a start codon that is four bytes long.
 Startcodons can be either four or three bytes long, as per the H.264 spec.
 @param bytes
 A buffer of bytes form which to derive a NALType.
 @warning The argument must point to a memoryblock of four bytes long.
 */
BOOL NALBytesHasFourByteStartCodon(uint8_t * buffer);

/*!
 @function BOOL NALBytesHasThreeByteStartCodon(uint8_t * buffer)
 This method tells if the given buffer has a start codon that is three bytes
 long. Startcodons can be either four or three bytes long, as per the H.264 spec.
 @param bytes
 A buffer of bytes form which to derive a NALType.
 @warning The argument must point to a memoryblock of four bytes long.
 */
BOOL NALBytesHasThreeByteStartCodon(uint8_t * buffer);

/*!
 @category NSData (NALUnit)
 Methods on NSData for working with H.264stream NAL-units.
 */
@interface NSData (NALUnit)

/*!
 @method - (NSString *) bytesAsString
 This method converts the internal buffer of bytes into a string that is a
 hexadecimal representation of the bytes.
 @return NSString
 A string that represents each byte of the interbal buffer as a hexadecimal number.
 */
- (NSString *) bytesAsString;

/*!
 @method - (NSData *) dataByReplacingNALStartCodonWithNALContentLength
 This method will encode the length of the internal buffer into four bytes. A 
 new NSData is created by copying the internal buffer and replacing the first
 four bytes with the bytes repesenting the receiver's length.
 @return NSData
 */
- (NSData *) dataByReplacingNALStartCodonWithNALContentLength;

/*!
 @property NALType NALType
 This method inspects the first 5 bytes of the receiver's internal buffer and 
 derives the NALType from it.
 */
@property (nonatomic, readonly) NALType NALType;
@end
