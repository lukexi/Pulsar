//
//  SCBuffer.h
//  Artikulator
//
//  Created by Luke Iannini on 6/19/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVOSC.h"
#import "SCServer.h"

typedef void(^SCBufferBlock)(void);

typedef NSString* SCBufferHeaderFormat;
typedef NSString* SCBufferSampleFormat;

extern SCBufferHeaderFormat const SCBufferHeaderFormatAIFF;
extern SCBufferHeaderFormat const SCBufferHeaderFormatWAV;
extern SCBufferHeaderFormat const SCBufferHeaderFormatIRCAM;
extern SCBufferHeaderFormat const SCBufferHeaderFormatNext;
extern SCBufferHeaderFormat const SCBufferHeaderFormatRaw;
extern SCBufferSampleFormat const SCBufferSampleFormatInt8;
extern SCBufferSampleFormat const SCBufferSampleFormatInt16;
extern SCBufferSampleFormat const SCBufferSampleFormatInt24;
extern SCBufferSampleFormat const SCBufferSampleFormatInt32;
extern SCBufferSampleFormat const SCBufferSampleFormatFloat;
extern SCBufferSampleFormat const SCBufferSampleFormatDouble;
extern SCBufferSampleFormat const SCBufferSampleFormatMulaw;
extern SCBufferSampleFormat const SCBufferSampleFormatAlaw;

@interface SCBuffer : NSObject

+ (SCBuffer *)bufferWithCapacity:(NSInteger)frames;
+ (SCBuffer *)bufferWithCapacity:(NSInteger)frames 
                    channelCount:(NSInteger)channels;

+ (SCBuffer *)bufferWithPath:(NSString *)path;

@property (nonatomic) SCBufferNumber bufferNumber;
@property (nonatomic) NSInteger numberOfFrames;
@property (nonatomic) NSInteger numberOfChannels;

- (void)setSamples:(NSArray *)samples;
- (void)writeToPath:(NSString *)path;
- (void)writeToPath:(NSString *)path
         completion:(SCBufferBlock)completion;
// workaround for SC floating point pitch handling failure wtfs.
// VVOSC is either not handling CGFloats correctly or we should be passing it floats instead of CGFloats (going with the latter for now)
// UPDATE these were caused by using CGFloats instead of floats!
- (void)setIntegerSamples:(NSArray *)samples;

- (void)free;

- (void)postContents;

#pragma mark - Message Creation
+ (OSCMessage *)b_allocReadChannelMessageWithPath:(NSString *)path 
                                     bufferNumber:(SCBufferNumber)bufferNumber
                                    startingFrame:(NSUInteger)startingFrame
                                   numberOfFrames:(NSUInteger)numberOfFrames;
+ (OSCMessage *)b_allocMessageWithBufferNumber:(SCBufferNumber)bufferNumber 
                                     numFrames:(NSInteger)numFrames 
                                   numChannels:(NSInteger)numChannels;
+ (OSCMessage *)b_setnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                                      samples:(NSArray *)samples;
    // Workaround message for bug where floating point buffers weren't being handled correctly — see note above
+ (OSCMessage *)b_setnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                               integerSamples:(NSArray *)samples;
+ (OSCMessage *)b_getnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                                 samplesCount:(NSInteger)numberOfSamples;
+ (OSCMessage *)b_freeMessageWithBufferNumber:(SCBufferNumber)bufferNumber;
+ (OSCMessage *)b_writeMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                          path:(NSString *)path
                                  headerFormat:(SCBufferHeaderFormat)headerFormat
                                  sampleFormat:(SCBufferSampleFormat)sampleFormat;

@end
