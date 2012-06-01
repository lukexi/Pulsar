//
//  NSArray+RTAdditions.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (RTAdditions)

- (id)rt_wrapObjectAtIndex:(NSUInteger)index;
- (id)rt_choose;
- (NSArray *)rt_scramble;
- (NSInteger)rt_integerSum;
- (CGFloat)rt_floatSum;

@end

typedef void(^PSArrayPairsBlock)(id left, id right);
typedef NSArray *(^PSCollectPairsBlock)(id left, id right);

@interface NSArray (EnumeratePairs)

- (void)ps_enumeratePairs:(PSArrayPairsBlock)block;

- (NSArray *)ps_collectPairs:(PSCollectPairsBlock)block;
- (NSDictionary *)ps_collectPairsAsDictionary:(PSCollectPairsBlock)block;

@end

@interface NSArray (Generators)

+ (NSArray *)rt_generatedRhythmFillingBeatCount:(NSUInteger)beatCount
                                  paddedToBeats:(BOOL)paddedToBeats
                                    minExponent:(NSInteger)minExponent
                                    maxExponent:(NSInteger)maxExponent;

+ (NSArray *)rt_generatedChordProgressionWithLength:(NSUInteger)length
                                            repeats:(NSUInteger)repeats;

@end