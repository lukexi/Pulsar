//
//  PSEvent.m
//  Pulsar
//
//  Created by Luke Iannini on 4/4/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSEvent.h"
#import "PSSubscripts.h"
#import "PSScale.h"
#import "NSObject+BlockRecognition.h"

typedef id(^PSEventBlock)(void);

@implementation PSEvent
{
    NSMutableDictionary *storage;
}

+ (PSEvent *)event
{
    return [self eventWithDictionary:@{}];
}

+ (PSEvent *)eventWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (NSDictionary *)parentEvent
{
    return @{};
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        storage = [[[self class] parentEvent] mutableCopy];
        [storage addEntriesFromDictionary:dictionary];
    }
    return self;
}

- (void)setObject:(id)object forKey:(id)aKey
{
    [storage setObject:object forKey:aKey];
}

- (id)objectForKey:(id)aKey
{
    return [storage objectForKey:aKey];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self setObject:obj forKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}
@end

@interface PSPitchEvent : PSEvent



@end

@implementation PSPitchEvent
{
    
}

+ (NSDictionary *)parentEvent
{
    __block NSDictionary *parentEvent = @{
        @"mtranspose":@0,
        @"gtranspose":@0.0,
        @"ctranspose":@0.0,
    
        @"octave":@5.0,
        @"root":@0.0,					// root of the scale
        @"degree":@0,
        @"scale":@[@0, @2, @4, @5, @7, @9, @11], 	// diatonic major scale
        @"stepsPerOctave":@12.0,
        @"detune":@0.0,					// detune in Hertz
        @"harmonic":@1.0,				// harmonic ratio
        @"octaveRatio":@2.0,
    
        @"note":^{
            CGFloat transposedDegree = [parentEvent[@"degree"] floatValue] + [parentEvent[@"mtranspose"] floatValue];
            id scale = parentEvent[@"scale"];
            
            CGFloat stepsPerOctave = [parentEvent[@"stepsPerOctave"] floatValue];
            if ([scale respondsToSelector:@selector(stepsPerOctave)])
            {
                stepsPerOctave = [scale stepsPerOctave];
            }
            
            NSUInteger scaleDegree = round(transposedDegree);
            CGFloat accidental = (transposedDegree - scaleDegree) * 10.0;
            
            CGFloat note = [scale performDegreeToKey:scaleDegree
                                      stepsPerOctave:stepsPerOctave
                                          accidental:accidental];
            return [NSNumber numberWithFloat:note];
        },
        @"midinote":^{
            id note = parentEvent[@"note"];
            id scale = parentEvent[@"scale"];
            CGFloat gtranspose = [parentEvent[@"gtranspose"] floatValue];
            CGFloat root = [parentEvent[@"root"] floatValue];
            CGFloat octave = [parentEvent[@"octave"] floatValue];
            CGFloat noteValue = [[note ps_value] floatValue];
            
            CGFloat stepsPerOctave = [parentEvent[@"stepsPerOctave"] floatValue];
            if ([scale respondsToSelector:@selector(stepsPerOctave)])
            {
                stepsPerOctave = [scale stepsPerOctave];
            }
            
            CGFloat octaveRatio = [parentEvent[@"octaveRatio"] floatValue];
            if ([scale respondsToSelector:@selector(octaveRatio)])
            {
                octaveRatio = [scale octaveRatio];
            }
            
            CGFloat midiNote = ((noteValue + gtranspose + root) / stepsPerOctave + octave - 5.0) * (12.0 * log2(octaveRatio) + 60.0);
            return [NSNumber numberWithFloat:midiNote];
        },
        @"detunedFreq":^{
            NSNumber *detune = parentEvent[@"detune"];
            id freq = parentEvent[@"freq"];
            CGFloat detunedFreq = [[freq ps_value] floatValue] + [detune floatValue];
            return [NSNumber numberWithFloat:detunedFreq];
        },
        @"freq":^{
            NSNumber *ctranspose = parentEvent[@"ctranspose"];
            id midinote = parentEvent[@"midinote"];
            NSNumber *harmonic = parentEvent[@"harmonic"];
            CGFloat transposedNote = [[midinote ps_value] floatValue] + [ctranspose floatValue];
            
            CGFloat freq = mtof(transposedNote) * [harmonic floatValue];
            
            return [NSNumber numberWithFloat:freq];
        }
    };
    return parentEvent;
}

@end


