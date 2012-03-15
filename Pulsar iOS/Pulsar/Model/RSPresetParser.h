//
//  SCPulsarPresetParser.h
//  Artikulator
//
//  Created by Luke Iannini on 8/22/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#define CGPointFromString NSPointFromString
#define NSStringFromCGPoint NSStringFromPoint
#endif

typedef void(^SCPulsarPresetParserCreatedSynthBlock)(NSString *synthName, NSString *defName, CGPoint location);
typedef void(^SCPulsarPresetParserConnectedSynthBlock)(NSString *sourceSynthName, NSString *destinationSynthName, NSString *destinationControlName, CGFloat amp);
typedef void(^SCPulsarPresetParserSetSynthControlBlock)(NSString *synthName, NSString *controlName, NSString *metaName, CGFloat amp);

@interface RSPresetParser : NSObject

+ (void)parsePreset:(NSDictionary *)snapshot
       createdSynth:(SCPulsarPresetParserCreatedSynthBlock)creationBlock
     connectedSynth:(SCPulsarPresetParserConnectedSynthBlock)connectionBlock
    setSynthControl:(SCPulsarPresetParserSetSynthControlBlock)setSynthControlBlock;

+ (NSString *)defNameOfSynthName:(NSString *)synthName inPreset:(NSDictionary *)preset;

@end
