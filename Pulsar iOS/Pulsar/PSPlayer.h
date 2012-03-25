//
//  PSPlayer.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *PSDurationKey = @"dur";

typedef void(^PSEventBlock)(NSDictionary *event);

@interface PSPlayer : NSObject

+ (PSPlayer *)playerWithPatterns:(NSDictionary *)patternsByKey
                          blocks:(NSArray *)blocks;

+ (PSPlayer *)playerWithPatterns:(NSDictionary *)patternsByKey
                           block:(PSEventBlock)block;

- (void)play;
- (void)stop;

@end
