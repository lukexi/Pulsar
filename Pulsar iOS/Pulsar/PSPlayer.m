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
#import "PSBlock.h"
#import "PSSubscripts.h"

typedef void(^PSArrayPairsBlock)(id left, id right);
typedef NSArray *(^PSCollectPairsBlock)(id left, id right);

@interface NSArray (EnumeratePairs)

- (void)ps_enumeratePairs:(PSArrayPairsBlock)block;

- (NSArray *)ps_collectPairs:(PSCollectPairsBlock)block;
- (NSDictionary *)ps_collectPairsAsDictionary:(PSCollectPairsBlock)block;

@end

@implementation NSArray (EnumeratePairs)

- (void)ps_enumeratePairs:(PSArrayPairsBlock)block
{
    NSAssert([self count] % 2 == 0, @"Must have an even number of elements to collect pairs");
    for (NSUInteger leftIndex = 0, rightIndex = 1;
         leftIndex < ([self count]);
         leftIndex+=2, rightIndex+=2)
    {
        id left = self[leftIndex];
        id right = self[rightIndex];
        block(left, right);
    }
}

- (NSArray *)ps_collectPairs:(PSCollectPairsBlock)block
{
    NSMutableArray *collected = [NSMutableArray arrayWithCapacity:
                                 [self count]];
    
    [self ps_enumeratePairs:^(id left, id right){
        NSArray *newPair = block(left, right);
        [collected addObjectsFromArray:newPair];
    }];
    
    return collected;
}

- (NSDictionary *)ps_collectPairsAsDictionary:(PSCollectPairsBlock)block
{
    NSMutableDictionary *collected = [NSMutableDictionary dictionaryWithCapacity:
                                      [self count] / 2];
    [self ps_enumeratePairs:^(id left, id right){
        NSArray *newPair = block(left, right);
        [collected setObject:newPair[1] forKey:newPair[0]];
    }];
    return collected;
}

@end

@implementation PSPlayer
{
    NSArray *patternsByKey;
    NSArray *streamsByKey;
    BOOL isPlaying;
    NSArray *blocks;
    PSClock *clock;
}

+ (PSPlayer *)playerWithPatterns:(NSArray *)patternsByKey block:(PSEventBlock)block
{
    return [self playerWithPatterns:patternsByKey blocks:@[block]];
}

+ (PSPlayer *)playerWithPatterns:(NSArray *)patternsByKey blocks:(NSArray *)blocks
{
    return [[self alloc] initWithPatterns:patternsByKey blocks:blocks];
}

- (id)initWithPatterns:(NSArray *)thePatternsByKey blocks:(NSArray *)theBlocks
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
    
    // Create a stream "instance" of each pattern that can be looped through
    streamsByKey = [patternsByKey ps_collectPairs:^NSArray *(id key, id value) {
        // Any object can implement asPattern to transform itself into a pattern;
        // By default an NSObject becomes a PSListPattern with one element,
        // but NSArray & NSSets become PSListPatterns with all their elements.
        PSPattern *pattern = [value asPattern];
        // We create an "instance" of the pattern as an iterable stream.
        PSStream *stream = [pattern asStream];
        return @[key, stream];
    }];
    
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
    
    // For each key in our dictionary of stream, create a new event by getting
    // the next value from each of the streams.
    NSMutableDictionary *event = [[[self class] prototypeDictionary] mutableCopy];
    
    [streamsByKey ps_enumeratePairs:^(id key, id obj) {
        PSStream *stream = obj;
        id nextValue = [stream next];
        
        // PSBlocks are the equivalent of PFuncs in SC — they return a new value
        // after evaluating the event as it has been created thus far.
        if ([nextValue isKindOfClass:[PSBlock class]])
        {
            nextValue = [nextValue evaluate:event];
        }
        event[key] = nextValue;
    }];
    
    //NSLog(@"Playing; %@", event);
    
    for (PSEventBlock eventBlock in blocks)
    {
        eventBlock(event);
    }
    
    NSTimeInterval duration = [[event objectForKey:PSDurationKey] doubleValue];
    [self performSelector:@selector(next) withObject:nil afterDelay:duration];
}

@end
