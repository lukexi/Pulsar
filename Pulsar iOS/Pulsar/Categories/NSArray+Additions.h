//
//  NSArray+Additions.h
//  Artikulator
//
//  Created by Luke Iannini on 8/16/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LXNumOf(x) sizeof(x) / sizeof(*x)

@interface NSArray (Additions)

+ (NSArray *)lx_arrayWithIntegers:(NSInteger[])integers length:(size_t)length;
+ (NSArray *)lx_arrayWithCGFloats:(CGFloat[])floats length:(size_t)length;
+ (NSArray *)lx_arrayWithFloats:(float[])floats length:(size_t)length;

@end
