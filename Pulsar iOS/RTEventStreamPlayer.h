//
//  RTEventStreamPlayer.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTRoutine.h"

typedef void(^RTEventBlock)(NSDictionary *event);

// Not quite complete yet, but the idea is we can pass a class (or list thereof) conforming to this protocol
// instead of passing the blocks and prototypeEvent manually and the RTEventStreamPlayer will take care of the rest
// SCSynth+RTEventStreamPlayer.h implements this so far.
@protocol RTEventStreamPlayerPlayable <NSObject>

+ (NSDictionary *)prototypeEvent;
+ (RTEventBlock)eventBlock;

@end

@interface RTRoutinePlayer : NSObject

+ (id)routinePlayerWithRoutine:(RTRoutine *)routine;

@property (nonatomic, strong) RTRoutine *routine;
@property (nonatomic, strong) id inValue;

- (void)play;
- (void)stop;

@end

@interface RTEventStreamPlayer : RTRoutinePlayer

+ (id)eventStreamPlayerWithStream:(RTStream *)stream blocks:(NSArray *)blocks;

@property (nonatomic, strong) RTStream *stream;
@property (nonatomic, strong) NSDictionary *prototypeEvent;

- (void)addBlock:(RTEventBlock)eventBlock;
- (void)removeBlock:(RTEventBlock)eventBlock;

@end
