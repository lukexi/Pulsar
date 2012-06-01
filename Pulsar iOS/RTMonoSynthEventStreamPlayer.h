//
//  RTMonoSynthEventStreamPlayer.h
//  Pulsar
//
//  Created by Luke Iannini on 6/1/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "RTEventStreamPlayer.h"
#import "SCSynth.h"

@interface RTMonoSynthEventStreamPlayer : RTEventStreamPlayer

@property (nonatomic, strong) SCSynth *synth;

@end
