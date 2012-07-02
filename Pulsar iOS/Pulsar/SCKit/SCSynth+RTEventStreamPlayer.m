//
//  SCSynth+RTEventStreamPlayer.m
//  Pulsar
//
//  Created by Luke Iannini on 6/1/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "SCSynth+RTEventStreamPlayer.h"
#import "NSDictionary+OSCAdditions.h"
#import "PSScale.h"
#import "SCGroup.h"
#import "PSSubscripts.h"

@implementation SCSynth (RTEventStreamPlayer)

+ (NSDictionary *)prototypeEvent
{
    static NSDictionary *prototypeEvent;
    if (!prototypeEvent)
    {
        prototypeEvent = @{
            @"instrument":@"simpleSynth",
            @"dur":@1.0,
            @"root":@60.0,
            @"amp":@0.1,
            @"degree":@0.0,
            @"octave":@5.0,
            @"scale":[PSScale scaleNamed:@"major"]
        };
    }
    return prototypeEvent;
}

+ (RTEventBlock)eventBlock
{
    static RTEventBlock eventBlock;
    if (!eventBlock)
    {
        eventBlock = ^(NSDictionary *event){
            
            NSMutableDictionary *synthEvent = [event mutableCopy];
            
            // Quick hack for now! but we should support arrays in any key that doesn't correspond to an array control... which requires knowledge of the synthDefs (or wait, no, I think SC does it by making you do [[1,2,3,4]] for things you don't want multi-synth expanded, which doesn't require synthDef knowledge after all)
            NSArray *degrees = synthEvent[@"degrees"];
            if (degrees)
            {
                [synthEvent removeObjectForKey:@"degrees"];
                for (NSNumber *degree in degrees)
                {
                    NSMutableDictionary *synthDegreeEvent = [synthEvent mutableCopy];
                    synthDegreeEvent[@"degree"] = degree;
                    [self spawnSynthForEvent:synthDegreeEvent];
                }
            }
            else
            {
                // Regular single-synth spawn
                [self spawnSynthForEvent:synthEvent];
            }
        };
    }
    return eventBlock;
}

+ (void)spawnSynthForEvent:(NSMutableDictionary *)synthEvent
{
    [self calculateFreqForEvent:synthEvent];
    
    NSString *instrument = synthEvent[@"instrument"];
    SCSynth *monoSynth = synthEvent[@"monoSynth"];
    SCGroup *group = synthEvent[@"group"];
    for (NSString *intermediateKey in @[@"instrument", @"scale", @"degree", @"root", @"group", @"monoSynth"])
    {
        [synthEvent removeObjectForKey:intermediateKey];
    }
    
    NSArray *OSCArguments = [synthEvent sc_asOSCArgsArray];
    //NSLog(@"Args: %@", OSCArguments);
    if (monoSynth)
    {
        //NSLog(@"Sending to monosynth: %@ %@", monoSynth, OSCArguments);
        [monoSynth set:OSCArguments];
    }
    else
    {
        //NSLog(@"Playing %@ with arguments: %@", instrument, OSCArguments);
        SCSynth *synth = [SCSynth synthWithName:instrument arguments:OSCArguments];
        if (group)
        {
            synth.target = group;
        }
        [synth send];
        
        // Hack for gates!
        NSNumber *gate = synthEvent[@"gate"];
        if (gate)
        {
            NSTimeInterval endTime = [synthEvent[@"dur"] doubleValue];
            double delayInSeconds = endTime;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [synth set:[@{ @"gate": @0 } sc_asOSCArgsArray]];
            });
        }
    }
}

+ (void)calculateFreqForEvent:(NSMutableDictionary *)synthEvent
{
    PSScale *scale = synthEvent[@"scale"];
    if (!synthEvent[@"freq"])
    {
        CGFloat degree = [synthEvent[@"degree"] floatValue];
        CGFloat octave = [synthEvent[@"octave"] floatValue];
        CGFloat root = [synthEvent[@"root"] floatValue];
        CGFloat rootFreq = mtof(root);
        CGFloat freq = [scale degreeToFreq:degree rootFreq:rootFreq octave:octave];
        synthEvent[@"freq"] = [NSNumber numberWithFloat:freq];
    }
}

@end
