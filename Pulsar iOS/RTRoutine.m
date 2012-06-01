//
//  RTRoutine.m
//  Routine
//
//  Created by Luke Iannini on 5/30/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTRoutine.h"

@interface RTRoutine ()

@property (nonatomic, strong) id yieldedValue;
@property (nonatomic, strong) id inValue;
@property (nonatomic, strong) NSConditionLock *condition;
@property (nonatomic, strong) RTYieldBlock yieldBlock;

@end

@implementation RTRoutine
{
    RTRoutineBlock _block;
    dispatch_queue_t routineQueue;
    BOOL done;
    
}
#define HAS_YIELDED 0
#define SHOULD_YIELD 1

+ (RTRoutine *)routineWithBlock:(RTRoutineBlock)block
{
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(RTRoutineBlock)block
{
    self = [super init];
    if (self) {
        _block = block;
        routineQueue = dispatch_queue_create("RTRoutine routineQueue", 0);
        _condition = [[NSConditionLock alloc] initWithCondition:HAS_YIELDED];
        
        __weak RTRoutine *weakSelf = self;
        _yieldBlock = ^(id returnValue) {
            weakSelf.yieldedValue = returnValue;
            [weakSelf.condition unlockWithCondition:HAS_YIELDED];
            [weakSelf.condition lockWhenCondition:SHOULD_YIELD];
            return weakSelf.inValue;
        };
        
        dispatch_async(routineQueue, ^{
            [weakSelf.condition lockWhenCondition:SHOULD_YIELD];
            _block(weakSelf.yieldBlock, weakSelf.inValue);
            weakSelf.yieldBlock(nil);
        });
    }
    return self;
}

- (id)rt_next:(id)inValue
{
    self.inValue = inValue;
    return [self rt_next];
}

- (id)rt_next
{
    if (done)
    {
        return nil;
    }
    [self.condition lock];
    [self.condition unlockWithCondition:SHOULD_YIELD];
    [self.condition lockWhenCondition:HAS_YIELDED];
    [self.condition unlockWithCondition:HAS_YIELDED];
    if (!self.yieldedValue)
    {
        done = YES;
    }
    return self.yieldedValue;
}



@end
