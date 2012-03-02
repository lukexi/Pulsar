//
//  OSCValue+Additions.m
//  Artikulator
//
//  Created by Luke Iannini on 8/20/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "OSCValue+Additions.h"

@implementation NSValue (TypeAdditions)

- (BOOL)sc_isIntegerType
{
    return strcmp([self objCType], @encode(int)) == 0 || 
           strcmp([self objCType], @encode(NSInteger)) == 0 || 
           strcmp([self objCType], @encode(NSUInteger)) == 0;
}

- (BOOL)sc_isFloatType
{
    return strcmp([self objCType], @encode(float)) == 0 || 
           strcmp([self objCType], @encode(double)) == 0 || 
           strcmp([self objCType], @encode(CGFloat)) == 0;
}

- (BOOL)sc_isBOOLType
{
    return strcmp([self objCType], @encode(BOOL)) == 0;
}

@end

@implementation OSCValue (OSCValue_Additions)

+ (OSCValue *)sc_valueWithObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]]) 
    {
        if ([object sc_isIntegerType])
        {
            //NSLog(@"returning int osc type for number: %@", object);
            return [OSCValue createWithInt:[object intValue]];
        }
        else if ([object sc_isFloatType])
        {
            //NSLog(@"returning float osc type for number: %@", object);
            return [OSCValue createWithFloat:[object floatValue]];       
        }
        else if ([object sc_isBOOLType])
        {
            //NSLog(@"returning bool osc type for number: %@", object);
            return [OSCValue createWithBool:[object boolValue]];
        }
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        return [OSCValue createWithString:object];
    }
    NSAssert1(NO, @"Couldn't convert object %@ into OSCValue", object);
    return nil;
}

- (id)sc_objectValue
{
    switch (type)	{
        case OSCValInt:
            return [NSNumber numberWithInt:*(int *)value];
        case OSCValFloat:
            return [NSNumber numberWithFloat:*(float *)value];
        case OSCValString:
            return (__bridge NSString *)value;
        case OSCValColor:
            return (__bridge id)value;
        case OSCValMIDI:
            return [NSString stringWithFormat:@"<OSCVal m %ld-%ld-%ld-%ld>",((Byte *)value)[0],((Byte *)value)[1],((Byte *)value)[2],((Byte *)value)[3]];
        case OSCValBool:
            return [NSNumber numberWithBool:*(BOOL *)value];
        case OSCValArrayOpen:
            return @"[";
        case OSCValArrayClose:
            return @"]";
        case OSCValNil:
            return [NSNull null];
        case OSCValInfinity:
            return [NSString stringWithFormat:@"<OSCVal infinity>"];
        case OSCValBlob:
            return [NSString stringWithFormat:@"<OSCVal blob: %@>",value];
        default:
            break;
    }
    return [NSString stringWithFormat:@"<OSCValue ?>"];
}

- (NSString *)sc_simpleDescription
{
    switch (type)	{
        case OSCValInt:
            return [NSString stringWithFormat:@"i%ld",*(int *)value];
        case OSCValFloat:
            return [NSString stringWithFormat:@"f%f",*(float *)value];
        case OSCValString:
            return [NSString stringWithFormat:@"\"%@\"",(__bridge id)value];
        case OSCValColor:
            return [NSString stringWithFormat:@"r%@",(__bridge id)value];
        case OSCValMIDI:
            return [NSString stringWithFormat:@"m%ld-%ld-%ld-%ld",((Byte *)value)[0],((Byte *)value)[1],((Byte *)value)[2],((Byte *)value)[3]];
        case OSCValBool:
            if (*(BOOL *)value)
                return [NSString stringWithString:@"bT"];
            else
                return [NSString stringWithString:@"bF"];
        case OSCValArrayOpen:
            return [NSString stringWithString:@"a["];
        case OSCValArrayClose:
            return [NSString stringWithString:@"a]"];
        case OSCValNil:
            return [NSString stringWithFormat:@"nil"];
        case OSCValInfinity:
            return [NSString stringWithFormat:@"infinity"];
        case OSCValBlob:
            return [NSString stringWithFormat:@"blob: %@",value];
        default:
            break;
    }
    return [NSString stringWithFormat:@"<OSCValue ?>"];
}

@end
