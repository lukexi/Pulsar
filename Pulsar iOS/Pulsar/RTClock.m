//
//  RTClock.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "RTClock.h"

@implementation RTClock
{
    NSDate *startDate;
}

+ (RTClock *)defaultClock
{
    RTClock *defaultClock = nil;
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
        _tempoBPS = 2;
        _beatsPerBar = 4;
        startDate = [NSDate date];
    }
    return self;
}

- (void)setTempoBPM:(CGFloat)tempoBPM
{
    self.tempoBPS = 60.0 / tempoBPM;
}

- (CGFloat)tempoBPM
{
    return self.tempoBPS * 60.0;
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
    return 1.0 / self.tempoBPS;
}

- (NSTimeInterval)nextTimeOnGrid
{
    return ceil([self beats]) * [self secondsPerBeat];
}

- (NSTimeInterval)timeToNextBeat
{
    return [self nextTimeOnGrid] - [self secondsSinceStart];
}

- (void)inBars:(CGFloat)numBars schedule:(RTClockEvent)event
{
    
}

- (void)scheduleEventAtNextBeat:(RTClockEvent)event
{
    double delayInSeconds = [self timeToNextBeat];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), event);
}

@end
