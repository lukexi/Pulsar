//
//  PSEvent.h
//  Pulsar
//
//  Created by Luke Iannini on 4/4/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSEvent : NSObject

+ (PSEvent *)event;
+ (PSEvent *)eventWithDictionary:(NSDictionary *)dictionary;

- (void)setObject:(id)object forKey:(id)aKey;
- (id)objectForKey:(id)aKey;

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

@end
