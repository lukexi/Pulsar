//
//  PSScale.m
//  Pulsar
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSScale.h"
#import "PSSubscripts.h"

float mtof(float f)
{
    if (f <= -1500) return(0);
    else if (f > 1499) return(mtof(1499));
    else return (8.17579891564 * exp(.0577622650 * f));
}

@interface PSScale ()

@end

@implementation PSScale

+ (PSScale *)scaleWithDegrees:(NSArray *)degrees name:(NSString *)name pitchesPerOctave:(NSUInteger)pitchesPerOctave
{
    return [[self alloc] initWithDegrees:degrees name:name pitchesPerOctave:pitchesPerOctave];
}

- (id)initWithDegrees:(NSArray *)degrees name:(NSString *)name pitchesPerOctave:(NSUInteger)pitchesPerOctave
{
    self = [super init];
    if (self) {
        _degrees = degrees;
        _name = name;
        _pitchesPerOctave = pitchesPerOctave;
    }
    return self;
}

- (CGFloat)stepsPerOctave
{
    return [self.tuning stepsPerOctave];
}

- (CGFloat)octaveRatio
{
    return [self.tuning octaveRatio];
}

- (NSUInteger)degreeAtIndex:(NSUInteger)index
{
    return [[self.degrees objectAtIndex:index] unsignedIntegerValue];
}

- (CGFloat)performDegreeToKey:(CGFloat)scaleDegree
               stepsPerOctave:(CGFloat)stepsPerOctave
                   accidental:(CGFloat)accidental
{
    stepsPerOctave = stepsPerOctave > 0 ? stepsPerOctave : [self stepsPerOctave];
    CGFloat baseKey = stepsPerOctave * (NSUInteger)(scaleDegree / [self count]) + [self degreeAtWrappedIndex:scaleDegree];
    
    if (accidental == 0)
    {
        return baseKey;
    }
    
    return baseKey + (accidental * (stepsPerOctave / 12.0f));
}

- (NSUInteger)degreeAtWrappedIndex:(NSUInteger)index
{
    NSUInteger wrappedIndex = index % [self count];
    return [self degreeAtIndex:wrappedIndex];
}

- (NSUInteger)count
{
    return [self.degrees count];
}

+ (NSDictionary *)scales
{
    static NSDictionary *scales;
    if (!scales)
    {
        NSData *data = [NSData dataWithContentsOfFile:@"PSScales.json"];
        NSError *error;
        scales = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!scales)
        {
            NSLog(@"Couldn't load scales: %@", error);
        }
    }
    return scales;
}

+ (PSScale *)scale:(NSString *)identifier
{
    NSDictionary *description = [self scales][identifier];
    if (!description)
    {
        return nil;
    }
    NSArray *degrees = description[@"degrees"];
    NSString *name = description[@"name"];
    NSNumber *pitchesPerOctave = description[@"pitchesPerOctave"];
    return [self scaleWithDegrees:degrees name:name pitchesPerOctave:[pitchesPerOctave unsignedIntegerValue]];
}

@end

@implementation PSTuning

+ (PSTuning *)tuningWithTunings:(NSArray *)tunings octaveRatio:(CGFloat)octaveRatio name:(NSString *)name
{
    return [[self alloc] initWithTunings:tunings octaveRatio:octaveRatio name:name];
}

- (id)initWithTunings:(NSArray *)tunings octaveRatio:(CGFloat)octaveRatio name:(NSString *)name
{
    self = [super init];
    if (self) {
        _tuning = tunings;
        _octaveRatio = octaveRatio;
        _name = name;
    }
    return self;
}

- (CGFloat)stepsPerOctave
{
    return log2(self.octaveRatio) * 12.0f;
}

+ (PSTuning *)defaultWithPitchesPerOctave:(NSUInteger)pitchesPerOctave
{
    return [self equalTemperedWithPitchesPerOctave:pitchesPerOctave];
}

+ (PSTuning *)equalTemperedWithPitchesPerOctave:(NSUInteger)pitchesPerOctave
{
    return [self tuningWithTunings:[self tuningsForEqualTemperedWithPtichesPerOctave:pitchesPerOctave]
                       octaveRatio:2.0
                              name:[self equalTemperedNameForPitchesPerOctave:pitchesPerOctave]];
}

+ (NSArray *)tuningsForEqualTemperedWithPtichesPerOctave:(NSUInteger)pitchesPerOctave
{
    NSMutableArray *tunings = [NSMutableArray arrayWithCapacity:pitchesPerOctave];
    CGFloat twelveOver = 12.0f / pitchesPerOctave;
    for (NSUInteger i = 0; i < pitchesPerOctave; i++)
    {
        CGFloat tuning = i * twelveOver;
        [tunings addObject:[NSNumber numberWithFloat:tuning]];
    }
    return tunings;
}

+ (NSString *)equalTemperedNameForPitchesPerOctave:(NSUInteger)pitchesPerOctave
{
    return [NSString stringWithFormat:@"ET%u", pitchesPerOctave];
}

@end