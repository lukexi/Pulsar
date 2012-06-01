//
//  SDDemandBuffer.m
//  SpringDudes
//
//  Created by Luke Iannini on 3/4/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SCDemandBuffer.h"
#import "Pulsar.h"

@interface SCDemandBuffer ()

@property (nonatomic, strong) SCBuffer *valuesBuffer;
@property (nonatomic, strong) SCBuffer *waitsBuffer;

@end

@implementation SCDemandBuffer
@synthesize valuesBuffer, waitsBuffer, values, waits;

- (SCBuffer *)waitsBuffer
{
    if (!waitsBuffer) 
    {
        self.waitsBuffer = [SCBuffer bufferWithCapacity:[self.values count]];
    }
    return waitsBuffer;
}

- (SCBuffer *)valuesBuffer
{
    if (!valuesBuffer) 
    {
        self.valuesBuffer = [SCBuffer bufferWithCapacity:[self.values count]];
    }
    return valuesBuffer;
}

- (void)sendSamples
{
    // Override to perform any of your own preparations in a subclass, but be sure to call super
    [self.valuesBuffer setSamples:self.values];
    [self.waitsBuffer setSamples:self.waits];
}

#define kFadeTime 0.5f

- (NSDictionary *)demandEnvGenInitialArguments
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:self.valuesBuffer.bufferNumber],
            @"i_pitchBufferNumber",
            [NSNumber numberWithInteger:self.waitsBuffer.bufferNumber],
            @"i_durationBufferNumber",
            nil];
}

- (NSDictionary *)timedEnvelopeInitialArguments
{
    NSTimeInterval eventDuration = [self duration];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:MAX(eventDuration - kFadeTime, 0)],
            @"i_duration",
            [NSNumber numberWithFloat:MIN(eventDuration, kFadeTime)],
            @"i_fadeTime",
            nil];
}

- (float)duration
{
    return [[self valueForKey:@"@sum.waits"] floatValue];
}

@end
