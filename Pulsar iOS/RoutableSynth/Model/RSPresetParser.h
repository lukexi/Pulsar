//
//  SCRoutableSynthPresetParser.h
//  Artikulator
//
//  Created by Luke Iannini on 8/22/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCRoutableSynthPresetParserCreatedSynthBlock)(NSString *synthName, NSString *defName, CGPoint location);
typedef void(^SCRoutableSynthPresetParserConnectedSynthBlock)(NSString *sourceSynthName, NSString *destinationSynthName, NSString *destinationControlName, CGFloat amp);
typedef void(^SCRoutableSynthPresetParserSetSynthControlBlock)(NSString *synthName, NSString *controlName, NSString *metaName, CGFloat amp);

@interface RSPresetParser : NSObject

+ (void)parsePreset:(NSDictionary *)snapshot
       createdSynth:(SCRoutableSynthPresetParserCreatedSynthBlock)creationBlock
     connectedSynth:(SCRoutableSynthPresetParserConnectedSynthBlock)connectionBlock
    setSynthControl:(SCRoutableSynthPresetParserSetSynthControlBlock)setSynthControlBlock;

+ (NSString *)defNameOfSynthName:(NSString *)synthName inPreset:(NSDictionary *)preset;

@end
