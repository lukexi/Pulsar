//
//  NSObject+BlockRecognition.m
//  Pulsar
//
//  Created by Luke Iannini on 4/4/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "NSObject+BlockRecognition.h"

typedef void(^PSTestBlock)(void);
typedef id(^PSIdBlock)(void);

@implementation NSObject (BlockRecognition)

- (id)ps_value
{
    if ([self ps_isBlock])
    {
        PSIdBlock blockSelf = (PSIdBlock)self;
        return blockSelf();
    }
    return self;
}

- (BOOL)ps_isBlock
{
    PSTestBlock aBlock = ^{};
    
    return [self ps_sharesSuperclassBesidesNSObjectWith:aBlock];
}

- (BOOL)ps_sharesSuperclassBesidesNSObjectWith:(id)object
{
    NSMutableSet *ourSuperclasses = [[self ps_superclasses] mutableCopy];
    NSMutableSet *theirSuperclasses = [[object ps_superclasses] mutableCopy];
    
    [ourSuperclasses removeObject:[NSObject class]];
    [theirSuperclasses removeObject:[NSObject class]];
    
    return [ourSuperclasses intersectsSet:theirSuperclasses];
}

- (NSSet *)ps_superclasses
{
    Class superClass = [self superclass];
    NSMutableSet *superclasses = [NSMutableSet set];
    while (superClass)
    {
        [superclasses addObject:superClass];
        superClass = [superClass superclass];
    }
    return superclasses;
}
@end
