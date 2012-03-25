//
//  PSClock.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSClock.h"

@implementation PSClock
{
    NSDate *startDate;
}

+ (PSClock *)defaultClock
{
    PSClock *defaultClock = nil;
    if (!defaultClock)
    {
        defaultClock = [[self alloc] init];
    }
    return defaultClock;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _tempo = 120;
        _beatsPerBar = 4;
        startDate = [NSDate date];
    }
    return self;
}

- (NSUInteger)beats
{
    return [self secondsSinceStart] / [self secondsPerBeat];
}

- (NSTimeInterval)secondsSinceStart
{
    return [[NSDate date] timeIntervalSinceDate:startDate];
}

- (NSTimeInterval)secondsPerBeat
{
    return 60.0f / self.tempo;
}

- (NSTimeInterval)nextTimeOnGrid
{
    return ceil([self beats]) * [self secondsPerBeat];
}

- (NSTimeInterval)timeToNextBeat
{
    return [self nextTimeOnGrid] - [self secondsSinceStart];
}

- (void)scheduleEventAtNextBeat:(PSClockEvent)event
{
    double delayInSeconds = [self timeToNextBeat];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), event);
}

@end
