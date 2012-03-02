//
//  NSArray+SCSynthAdditions.m
//  Artikulator
//
//  Created by Luke Iannini on 6/30/10.
//  Copyright 2010 P.W. Worm & Co & Sons All rights reserved.
//

#import "NSArray+SCSynthAdditions.h"
#import "VVOSC.h"

@implementation NSArray (SCSynthAdditions)

- (NSArray *)asSCEnvLevelsArrayWithWaits:(NSArray *)waits
{
    // This method implements the Env.asArray method from SCLang using VVOSC primitives.
    OSCValue *shapeNumber = [OSCValue createWithInt:3]; // 3=sin, 1=lin, 2=exp, 6=sqr
    OSCValue *curveValue  = [OSCValue createWithInt:0];
    
    NSMutableArray *contents = [NSMutableArray arrayWithCapacity:[waits count] * 4 + 6];
    
    [contents addObject:[OSCValue createWithArrayOpen]];
    
    [contents addObject:[OSCValue createWithInt:[[self objectAtIndex:0] intValue]]];
    [contents addObject:[OSCValue createWithInt:[waits count]]];
    [contents addObject:[OSCValue createWithInt:-99]]; // release node
    [contents addObject:[OSCValue createWithInt:-99]]; // loop node
    
    for (NSInteger i = 0; i < [waits count]; i++)
    {
        [contents addObject:[OSCValue createWithInt:[[self objectAtIndex:i+1] intValue]]];
        [contents addObject:[OSCValue createWithFloat:[[waits objectAtIndex:i] floatValue]]];
        [contents addObject:shapeNumber];
        [contents addObject:curveValue];
    }
    
    [contents addObject:[OSCValue createWithArrayClose]];
    
    return contents;
}

@end
