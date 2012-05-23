//
//  SCBuffer.m
//  Artikulator
//
//  Created by Luke Iannini on 6/19/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCBuffer.h"
#import "SCServer.h"
#import "SCBundle.h"

SCBufferHeaderFormat const SCBufferHeaderFormatAIFF = @"aiff";
SCBufferHeaderFormat const SCBufferHeaderFormatWAV = @"wav";
SCBufferHeaderFormat const SCBufferHeaderFormatIRCAM = @"ircam";
SCBufferHeaderFormat const SCBufferHeaderFormatNext = @"next";
SCBufferHeaderFormat const SCBufferHeaderFormatRaw = @"raw";
SCBufferSampleFormat const SCBufferSampleFormatInt8 = @"int8";
SCBufferSampleFormat const SCBufferSampleFormatInt16 = @"int16";
SCBufferSampleFormat const SCBufferSampleFormatInt24 = @"int24";
SCBufferSampleFormat const SCBufferSampleFormatInt32 = @"int32";
SCBufferSampleFormat const SCBufferSampleFormatFloat = @"float";
SCBufferSampleFormat const SCBufferSampleFormatDouble = @"double";
SCBufferSampleFormat const SCBufferSampleFormatMulaw = @"mulaw";
SCBufferSampleFormat const SCBufferSampleFormatAlaw = @"alaw";

@interface SCBuffer ()

- (void)logSCLangMessageToRecreateBuffer:(NSArray *)samples;

@end

@implementation SCBuffer
@synthesize bufferNumber, numberOfFrames, numberOfChannels;

+ (SCBuffer *)bufferWithCapacity:(NSInteger)frames
{
    return [[self class] bufferWithCapacity:frames channelCount:1];
}

+ (SCBuffer *)bufferWithCapacity:(NSInteger)frames channelCount:(NSInteger)channels
{
    SCBuffer *buffer = [[[self class] alloc] init];
    buffer.bufferNumber = [[SCServer sharedServer] requestBufferNumber];
    buffer.numberOfFrames = frames;
    buffer.numberOfChannels = channels;
    
    OSCMessage *message = [[self class] b_allocMessageWithBufferNumber:buffer.bufferNumber 
                                                             numFrames:buffer.numberOfFrames 
                                                           numChannels:buffer.numberOfChannels];
    [SCBundle sendMessage:message];
    
    [SCBundle sync];
    
    return buffer;
}

+ (SCBuffer *)bufferWithPath:(NSString *)path
{
    SCBuffer *buffer = [[[self class] alloc] init];
    buffer.bufferNumber = [[SCServer sharedServer] requestBufferNumber];
    
    OSCMessage *message = [[self class] b_allocReadChannelMessageWithPath:path 
                                                             bufferNumber:buffer.bufferNumber 
                                                            startingFrame:0 
                                                           numberOfFrames:-1];
    [SCBundle sendMessage:message];
    
    [SCBundle sync];
    
    return buffer;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p bufferNumber:%i numberOfFrames:%i numberOfChannels:%i>", [self class], self, (int)self.bufferNumber, (int)self.numberOfFrames, (int)self.numberOfChannels];
}

- (void)setSamples:(NSArray *)samples
{
    //[self logSCLangMessageToRecreateBuffer:samples];
    // We're using the server's /synced messages, but it also sends /done messages for buffers — would that be better?
    OSCMessage *message = [[self class] b_setnMessageWithBufferNumber:self.bufferNumber startingIndex:0 samples:samples];
    [SCBundle sendMessage:message];
}

- (void)writeToPath:(NSString *)path
{
    [self writeToPath:path completion:nil];
}

- (void)writeToPath:(NSString *)path
         completion:(SCBufferBlock)completion
{
    OSCMessage *message = [[self class] b_writeMessageWithBufferNumber:self.bufferNumber 
                                                                  path:path 
                                                          headerFormat:SCBufferHeaderFormatAIFF 
                                                          sampleFormat:SCBufferSampleFormatInt24];
    [SCBundle sendMessage:message];
    
    [SCBundle syncWithCompletion:completion];
}

- (void)setIntegerSamples:(NSArray *)samples
{
    [self logSCLangMessageToRecreateBuffer:samples];
    OSCMessage *message = [SCBuffer b_setnMessageWithBufferNumber:self.bufferNumber startingIndex:0 integerSamples:samples];
    [SCBundle sendMessage:message];
}

#define kMaxSamplesPerMessage 10000
- (void)postContents
{
    [SCBundle bundleMessages:^{
        for (NSInteger i = 0; i < self.numberOfFrames; i = i + kMaxSamplesPerMessage) 
        {
            NSUInteger samplesCount = kMaxSamplesPerMessage;
            if (i + kMaxSamplesPerMessage > self.numberOfFrames) 
            {
                samplesCount = self.numberOfFrames - i;
            }
            OSCMessage *message = [SCBuffer b_getnMessageWithBufferNumber:self.bufferNumber 
                                                            startingIndex:i 
                                                             samplesCount:samplesCount];
            NSLog(@"Message from %i to %i (max %i)", (int)i, (int)(i + samplesCount), (int)self.numberOfFrames);
            [SCBundle sendMessage:message];
        }
    }];
}

- (void)free
{
    OSCMessage *message = [SCBuffer b_freeMessageWithBufferNumber:self.bufferNumber];
    [SCBundle sendMessage:message];
    
    [[SCServer sharedServer] freeBufferNumber:self.bufferNumber];
}

- (void)logSCLangMessageToRecreateBuffer:(NSArray *)samples
{
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:[samples count]];
    for (NSNumber *sample in samples) 
    {
        //[strings addObject:[NSString stringWithFormat:@"%f", [sample floatValue]]];
        [strings addObject:[NSString stringWithFormat:@"%@", sample]];
    }
    NSLog(@"~buffer%i = Buffer.loadCollection(s, [%@]);", (int)self.bufferNumber, [strings componentsJoinedByString:@","]);
}

#pragma mark - Message Creation

// To only read a single channel
+ (OSCMessage *)b_allocReadChannelMessageWithPath:(NSString *)path 
                                     bufferNumber:(SCBufferNumber)bufferNumber
                                    startingFrame:(NSUInteger)startingFrame
                                   numberOfFrames:(NSUInteger)numberOfFrames
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_allocReadChannel"];
    [message addInt:bufferNumber];
    [message addString:path];
    [message addInt:startingFrame]; // Starting frame
    [message addInt:numberOfFrames]; // Number of frames
    [message addInt:0]; // First channel only (granulators only support mono files)
    return message;
}

+ (OSCMessage *)b_allocMessageWithBufferNumber:(SCBufferNumber)bufferNumber 
                                     numFrames:(NSInteger)numFrames 
                                   numChannels:(NSInteger)numChannels
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_alloc"];
    [message addInt:bufferNumber];
    [message addInt:numFrames];
    [message addInt:numChannels];
    return message;
}

// NOTE: b_setn supports setting multiple ranges in one call if desired
// by starting a new [index, [samples]] sequence after the first one.
// We don't need this for anything yet so it's not yet implemented.
+ (OSCMessage *)b_setnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                                      samples:(NSArray *)samples
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_setn"];
    [message addInt:bufferNumber];
    [message addInt:startingIndex];
    [message addInt:[samples count]];
    for (NSNumber *sample in samples)
    {
        [message addFloat:[sample floatValue]];
    }
    return message;
}

// Using integer b_setn for pitches since SC seems unable to handle floating point pitches???
+ (OSCMessage *)b_setnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                               integerSamples:(NSArray *)samples
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_setn"];
    [message addInt:bufferNumber];
    [message addInt:startingIndex];
    [message addInt:[samples count]];
    for (NSNumber *sample in samples) 
    {
        [message addInt:[sample intValue]];
    }
    return message;
}

+ (OSCMessage *)b_getnMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                startingIndex:(NSInteger)startingIndex
                                 samplesCount:(NSInteger)numberOfSamples
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_getn"];
    [message addInt:bufferNumber];
    [message addInt:startingIndex];
    [message addInt:numberOfSamples];
    return message;
}

+ (OSCMessage *)b_writeMessageWithBufferNumber:(SCBufferNumber)bufferNumber
                                          path:(NSString *)path
                                  headerFormat:(SCBufferHeaderFormat)headerFormat
                                  sampleFormat:(SCBufferSampleFormat)sampleFormat
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_write"];
    [message addInt:bufferNumber];
    [message addString:path];
    [message addString:headerFormat];
    [message addString:sampleFormat];
    return message;
}

+ (OSCMessage *)b_freeMessageWithBufferNumber:(SCBufferNumber)bufferNumber
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/b_free"];
    [message addInt:bufferNumber];
    return message;
}

@end
