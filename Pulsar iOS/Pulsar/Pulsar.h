//
//  Pulsar.h
//  Pulsar
//
//  Created by Luke Iannini on 12/14/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCKit.h"
#import "RSServerObject.h"
#import "RSGraph.h"
#import "RSInput.h"
#import "RSNode.h"
#import "RSOutNode.h"
#import "RSPresetParser.h"
#import "RSSynthDef.h"
#import "RSSynthDefControl.h"
#import "RSWire.h"
#import "RTClock.h"
#import "PSPlayer.h"
#import "PSPattern.h"
#import "PSStream.h"
#import "PSPatternables.h"
#import "PSSubscripts.h"
#import "PSScale.h"
#import "PSBlock.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "RSGraphEditorViewController.h"
#import "RSGraphListViewController.h"
#import "RSNodeControlInlet.h"
#import "RSUGenListViewController.h"
#import "RSGraphNoteEditorViewController.h"
#endif

typedef void(^RSGraphCreationBlock)(RSGraph *emptyGraph);

@interface Pulsar : NSObject

+ (Pulsar *)sharedPulsar;

- (RSGraph *)graph;
- (RSGraph *)graphNamed:(NSString *)name creation:(RSGraphCreationBlock)creationBlock; // Returns a pre-existing graph with this name if one exists
- (RSSynthDef *)synthDefNamed:(NSString *)name;

@end
