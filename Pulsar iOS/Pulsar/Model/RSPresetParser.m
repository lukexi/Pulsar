//
//  SCPulsarPresetParser.m
//  Artikulator
//
//  Created by Luke Iannini on 8/22/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "RSPresetParser.h"

@interface RSPresetParser ()

+ (BOOL)handleConnectionKey:(NSString *)routingKey 
                      atAmp:(NSNumber *)amp 
                  withBlock:(SCPulsarPresetParserConnectedSynthBlock)connectionBlock;

+ (void)handleSettingKey:(NSString *)routingKey 
                   atAmp:(NSNumber *)amp 
               withBlock:(SCPulsarPresetParserSetSynthControlBlock)setSynthControlBlock;

@end

@implementation RSPresetParser

+ (void)parsePreset:(NSDictionary *)snapshot
       createdSynth:(SCPulsarPresetParserCreatedSynthBlock)creationBlock
     connectedSynth:(SCPulsarPresetParserConnectedSynthBlock)connectionBlock
    setSynthControl:(SCPulsarPresetParserSetSynthControlBlock)setSynthControlBlock
{
    NSArray *synths = [snapshot objectForKey:@"synths"];
    NSDictionary *params = [snapshot objectForKey:@"params"];
    
    for (NSArray *nameAndDef in synths)
    {
        NSString *synthName = [nameAndDef objectAtIndex:0];
        NSString *defName = [nameAndDef objectAtIndex:1];
        
        CGPoint location = CGPointZero;
        if ([nameAndDef count] > 2) 
        {
            NSString *pointString = [nameAndDef objectAtIndex:2];
            location = CGPointFromString(pointString);
        }
        
        if (creationBlock) 
        {
            creationBlock(synthName, defName, location);
        }
    }
    
    for (NSString *routingKey in params) 
    {
        NSNumber *amp = [params objectForKey:routingKey];
        
        if (![self handleConnectionKey:routingKey atAmp:amp withBlock:connectionBlock]) 
        {
            [self handleSettingKey:routingKey atAmp:amp withBlock:setSynthControlBlock];
        }
    }
}

// Has form "FromSynthName=>ToSynthName" or "FromSynthName=>ToSynthName.controlName"
+ (BOOL)handleConnectionKey:(NSString *)routingKey 
                      atAmp:(NSNumber *)amp 
                  withBlock:(SCPulsarPresetParserConnectedSynthBlock)connectionBlock
{
    NSArray *connectionItems = [routingKey componentsSeparatedByString:@"=>"];
    BOOL isConnection = [connectionItems count] == 2;
    if (!isConnection)
    {
        return NO;
    }
    
    NSString *sourceSynthName = [connectionItems objectAtIndex:0];
    
    NSString *destination = [connectionItems objectAtIndex:1];
    NSArray *destinationItems = [destination componentsSeparatedByString:@"."];
    
    NSString *destinationSynthName = destination;
    NSString *destinationControlName = nil;
    
    BOOL isSpecificConnection = [destinationItems count] == 2;
    if (isSpecificConnection) 
    {
        destinationSynthName = [destinationItems objectAtIndex:0];
        destinationControlName = [destinationItems objectAtIndex:1];
    }
    
    if (connectionBlock) 
    {
        connectionBlock(sourceSynthName, destinationSynthName, destinationControlName, [amp floatValue]);
    }
    //NSLog(@"Connecting %@ to %@.%@", sourceSynthName, destinationSynthName, destinationControlName);
    
    return YES;
}

// Has form "SynthName.controlName" or "SynthName.controlName.property"
+ (void)handleSettingKey:(NSString *)routingKey 
                   atAmp:(NSNumber *)amp 
               withBlock:(SCPulsarPresetParserSetSynthControlBlock)setSynthControlBlock
{
    NSArray *components = [routingKey componentsSeparatedByString:@"."];
    if ([components count] <= 1) 
    {
        NSLog(@"Couldn't parse routing key: %@", routingKey);
        return;
    }
    
    BOOL isMetaSetting = [components count] == 3;
    NSString *synthName = [components objectAtIndex:0];
    NSString *controlName = [components objectAtIndex:1];
    NSString *metaName = isMetaSetting ? [components objectAtIndex:2] : @"center";
    
    if (setSynthControlBlock) 
    {
        setSynthControlBlock(synthName, controlName, metaName, [amp floatValue]);
    }
}

+ (NSString *)defNameOfSynthName:(NSString *)synthName inPreset:(NSDictionary *)preset
{
    NSArray *synths = [preset objectForKey:@"synths"];
    for (NSArray *nameAndDef in synths) 
    {
        if ([[nameAndDef objectAtIndex:0] isEqualToString:synthName])
        {
            return [nameAndDef objectAtIndex:1];
        }
    }
    return nil;
}

@end
