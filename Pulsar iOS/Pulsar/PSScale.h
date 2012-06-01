//
//  PSScale.h
//  Pulsar
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define PS_EXTERN_C extern "C"
#else
#define PS_EXTERN_C extern
#endif

PS_EXTERN_C float mtof(float f);
PS_EXTERN_C float midiratio(float midi);

@class PSTuning;
@interface PSScale : NSObject

+ (PSScale *)scaleWithDegrees:(NSArray *)degrees
                         name:(NSString *)name
             pitchesPerOctave:(NSUInteger)pitchesPerOctave;

@property (nonatomic, strong, readonly) NSArray *degrees;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger pitchesPerOctave;
@property (nonatomic, readonly) CGFloat stepsPerOctave;
@property (nonatomic, readonly) CGFloat octaveRatio;
@property (nonatomic, readonly) PSTuning *tuning;

- (NSUInteger)count;
- (NSUInteger)degreeAtIndex:(NSUInteger)index;
- (NSUInteger)degreeAtWrappedIndex:(NSUInteger)index;

- (CGFloat)degreeToRatio:(CGFloat)degree octave:(CGFloat)octave;
- (CGFloat)degreeToFreq:(CGFloat)degree rootFreq:(CGFloat)rootFreq octave:(CGFloat)octave;

- (CGFloat)performDegreeToKey:(CGFloat)scaleDegree
               stepsPerOctave:(CGFloat)stepsPerOctave
                   accidental:(CGFloat)accidental;

- (NSArray *)semitones;
- (NSArray *)ratios;

// Scales
+ (PSScale *)scaleNamed:(NSString *)identifier;

@end

@interface PSTuning : NSObject

+ (PSTuning *)tuningWithTunings:(NSArray *)tunings octaveRatio:(CGFloat)octaveRatio name:(NSString *)name;
+ (PSTuning *)defaultWithPitchesPerOctave:(NSUInteger)pitchesPerOctave;

@property (nonatomic, strong, readonly) NSArray *tuning;
@property (nonatomic, readonly) CGFloat octaveRatio;
@property (nonatomic, strong, readonly) NSString *name;

- (CGFloat)stepsPerOctave;
- (CGFloat)tuningAtWrappedIndex:(NSUInteger)index;

@end