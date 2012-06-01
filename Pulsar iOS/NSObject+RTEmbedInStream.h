//
//  NSObject+RTEmbedInStream.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^RTYieldBlock)(id returnValue);
typedef void(^RTRoutineBlock)(RTYieldBlock yield, id inValue);

@protocol RTEmbedInStream <NSObject>

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue;
- (id)rt_value:(id)inValue;
- (id)rt_value;

- (id)rt_next:(id)inValue;
- (id)rt_next;
- (id)rt_asStream;

@end

@interface NSObject (RTEmbedInStream) <RTEmbedInStream>

@end
