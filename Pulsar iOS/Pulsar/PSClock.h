//
//  PSClock.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PSClockEvent)(void);

@interface PSClock : NSDictionary

+ (PSClock *)defaultClock;

@property (nonatomic) NSUInteger tempo;
@property (nonatomic) NSUInteger beatsPerBar;

- (void)scheduleEventAtNextBeat:(PSClockEvent)event;

@end
