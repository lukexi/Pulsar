//
//  RTEventStreamPlayer.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTEventStreamPlayer.h"

@implementation RTRoutinePlayer

+ (id)routinePlayerWithRoutine:(RTRoutine *)routine
{
    RTRoutinePlayer *routinePlayer = [[self alloc] init];
    routinePlayer.routine = routine;
    return routinePlayer;
}

- (void)next
{
    id yieldedValue = [self.routine rt_next:self.inValue];
    if (!yieldedValue)
    {
        [self stop];
        return;
    }
    
    NSTimeInterval waitTime = [self playAndReturnNextDeltaWithValue:yieldedValue];
    [self performSelector:@selector(next) withObject:nil afterDelay:waitTime];
}

- (NSTimeInterval)playAndReturnNextDeltaWithValue:(id)value
{
    NSNumber *number = value;
    return [number doubleValue];
}

- (void)play
{
    [self next];
}

- (void)stop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
}

@end

@interface RTEventStreamPlayer ()
@property (nonatomic, strong) NSMutableArray *blocks;
@end

@implementation RTEventStreamPlayer

+ (id)eventStreamPlayerWithStream:(RTStream *)stream blocks:(NSArray *)blocks
{
    RTEventStreamPlayer *eventStreamPlayer = [(RTEventStreamPlayer *)[self alloc] initWithStream:stream];
    eventStreamPlayer.blocks = [blocks mutableCopy] ?: [NSMutableArray array];
    return eventStreamPlayer;
}

- (id)initWithStream:(RTStream *)stream
{
    self = [super init];
    if (self)
    {
        self.stream = stream;
        __weak RTStream *weakStream = stream;
        self.routine = [RTRoutine routineWithBlock:^(RTYieldBlock yield, id inValue) {
            [weakStream embedInStream:yield inValue:inValue];
        }];
        self.prototypeEvent = @{@"dur":@1.0};
    }
    return self;
}

- (void)setPrototypeEvent:(NSDictionary *)prototypeEvent
{
    self.inValue = prototypeEvent;
}

- (NSDictionary *)prototypeEvent
{
    return self.inValue;
}

- (CGFloat)tempo
{
    return 1;
}

- (void)addBlock:(RTEventBlock)eventBlock
{
    [self.blocks addObject:eventBlock];
}

- (void)removeBlock:(RTEventBlock)eventBlock
{
    [self.blocks removeObject:eventBlock];
}

- (NSTimeInterval)playAndReturnNextDeltaWithValue:(id)value
{
    NSDictionary *event = value;
    NSNumber *duration = [event objectForKey:@"dur"];
    NSNumber *stretch = [event objectForKey:@"stretch"];
    CGFloat stretchValue = stretch ? [stretch floatValue] : 1.0;
    
    for (RTEventBlock eventBlock in [self.blocks copy])
    {
        eventBlock(event);
    }
    
    return [duration doubleValue] * [self tempo] * stretchValue;
}

@end
