//
//  PSPlayer.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSPlayer.h"
#import "PSPattern.h"
#import "PSStream.h"
#import "PSClock.h"

@implementation PSPlayer
{
    NSDictionary *patternsByKey;
    NSDictionary *streamsByKey;
    BOOL isPlaying;
    NSArray *blocks;
    PSClock *clock;
}

+ (PSPlayer *)playerWithPatterns:(NSDictionary *)patternsByKey blocks:(NSArray *)blocks
{
    return [[self alloc] initWithDescription:patternsByKey blocks:blocks];
}

+ (PSPlayer *)playerWithPatterns:(NSDictionary *)patternsByKey block:(PSEventBlock)block
{
    return [self playerWithPatterns:patternsByKey blocks:@[block]];
}

- (id)initWithDescription:(NSDictionary *)thePatternsByKey blocks:(NSArray *)theBlocks
{
    self = [super init];
    if (self) {
        clock = [PSClock defaultClock];
        patternsByKey = thePatternsByKey;
        blocks = theBlocks;
    }
    return self;
}

- (void)play
{
    isPlaying = YES;
    NSMutableDictionary *streams = [NSMutableDictionary dictionaryWithCapacity:
                                    [patternsByKey count]];
    [patternsByKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        PSPattern *pattern = [obj asPattern];
        [streams setObject:[pattern asStream] forKey:key];
    }];
    
    streamsByKey = streams;
    
    [clock scheduleEventAtNextBeat:^{
        [self next];
    }];
}

- (void)stop
{
    isPlaying = NO;
}

+ (NSDictionary *)prototypeDictionary
{
    static NSDictionary *prototypeDictionary = nil;
    if (!prototypeDictionary)
    {
        prototypeDictionary = @{PSDurationKey:@1.0};
    }
    return prototypeDictionary;
}

- (void)next
{
    if (!isPlaying)
    {
        return;
    }
    NSMutableDictionary *event = [[[self class] prototypeDictionary] mutableCopy];
    [streamsByKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PSStream *stream = obj;
        [event setObject:[stream next] forKey:key];
    }];
    
    for (PSEventBlock eventBlock in blocks)
    {
        eventBlock(event);
    }
    
    NSTimeInterval duration = [[event objectForKey:PSDurationKey] doubleValue];
    [self performSelector:@selector(next) withObject:nil afterDelay:duration];
}

@end
