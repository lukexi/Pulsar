//
//  PSSubscripts.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1

@interface NSDictionary (Subscripts)

- (id)objectForKeyedSubscript:(id)key;

@end

@interface NSMutableDictionary (Subscripts)

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end

@interface NSArray (Subscripts)

- (id)objectAtIndexedSubscript:(NSInteger)idx;

@end

@interface NSMutableArray (Subscripts)

- (void)setObject:(id)obj atIndexedSubscript:(NSInteger)idx;

@end

#endif