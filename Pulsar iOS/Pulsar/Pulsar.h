//
//  Pulsar.h
//  Pulsar
//
//  Created by Luke Iannini on 12/14/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCKit.h"
#import "RSGraphEditorViewController.h"
#import "RSGraphListViewController.h"
#import "RSNodeControlInlet.h"
#import "RSUGenListViewController.h"
#import "RSGraphNoteEditorViewController.h"
#import "RSServerObject.h"
#import "RSGraph.h"
#import "RSInput.h"
#import "RSNode.h"
#import "RSOutNode.h"
#import "RSPresetParser.h"
#import "RSSynthDef.h"
#import "RSSynthDefControl.h"
#import "RSWire.h"

@interface Pulsar : NSObject

+ (Pulsar *)sharedPulsar;

- (RSGraph *)graph;
- (RSGraph *)graphNamed:(NSString *)name; // Returns a pre-existing graph with this name if one exists
- (RSSynthDef *)synthDefNamed:(NSString *)name;

@end
