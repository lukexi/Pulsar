//
//  SCBus.m
//  Artikulator
//
//  Created by Luke Iannini on 6/25/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCBus.h"

#define kSCMainOutputBusID 0

@interface SCBus ()
{
    BOOL isFreed;
}

@end

@implementation SCBus
@synthesize busID, numberOfChannels, rate;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p BusID:%i NumberOfChannels:%i Rate:%@>", [self class], self, (int)self.busID, (int)self.numberOfChannels, self.rate == SCSynthAudioRate ? @"Audio" : @"Control"];
}

+ (SCBus *)mainOutputBus
{
    static SCBus *mainOutputBus = nil;
    if (!mainOutputBus) 
    {
        mainOutputBus = [[self alloc] init];
        mainOutputBus.numberOfChannels = 2;
        mainOutputBus.rate = SCSynthAudioRate;
        mainOutputBus.busID = kSCMainOutputBusID;
    }
    return mainOutputBus;
}

+ (SCBus *)busWithChannels:(NSUInteger)channels rate:(SCSynthRate)rate
{
    SCBus *bus = [[self alloc] init];
    bus.numberOfChannels = channels;
    bus.busID = [[SCServer sharedServer] requestBusID];
    bus.rate = rate;
    
    NSInteger remainingChannelsToReserve = channels - 1;
    
    // Reserve next channels for this bus.
    for (NSUInteger i = 0; i < remainingChannelsToReserve; i++)
    {
        [[SCServer sharedServer] requestBusID];
    }
    return bus;
}

- (void)free
{
    if (!isFreed) 
    {
        for (NSInteger i = 0; i < self.numberOfChannels; i++) 
        {
            [[SCServer sharedServer] freeBusID:self.busID + i];
        }
        isFreed = YES;
    }
}

- (void)dealloc
{
    [self free];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    SCBus *bus = [[[self class] alloc] init];
    bus.busID = self.busID;
    bus.numberOfChannels = self.numberOfChannels;
    bus.rate = self.rate;
    return bus;
}

@end
