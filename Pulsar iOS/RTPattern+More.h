//
//  RTPattern+More.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTPattern.h"

typedef NSArray *(^RTPSequenceGenerator)(void);

@interface RTPattern (More)

+ (RTPattern *)PnLazyWithFunc:(RTFuncStreamFunc)patternFunc;
+ (RTPattern *)PnLazySequenceWithGenerator:(RTPSequenceGenerator)generatorFunc repeats:(id)repeats;

// Phase is 0.0-1.0
+ (RTPattern *)PSinWithSteps:(NSNumber *)steps phase:(NSNumber *)phase mul:(CGFloat)mul add:(CGFloat)add;
+ (RTPattern *)PSinWithSteps:(NSNumber *)steps phase:(NSNumber *)phase from0To:(CGFloat)value;


@end
