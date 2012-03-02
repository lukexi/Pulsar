//
//  SCIDAllocator.m
//  Artikulator
//
//  Created by Luke Iannini on 9/18/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "SCIDAllocator.h"

@interface SCIDAllocator ()

@property (nonatomic, strong) NSMutableArray *freedIDs;
@property (nonatomic) NSInteger position;

@end

@implementation SCIDAllocator
@synthesize freedIDs;
@synthesize position;
@synthesize name;
#if SCTestAllocatedNodeIDs
@synthesize allocatedIDs;
#endif

+ (id)IDAllocatorStartingAt:(NSInteger)position
{
    SCIDAllocator *allocator = [[self alloc] init];
    allocator.position = position;
    return allocator;
}

- (id)init 
{
    self = [super init];
    if (self) 
    {
        self.freedIDs = [NSMutableArray array];
#if SCTestAllocatedNodeIDs
        self.allocatedIDs = [NSMutableArray array];
#endif
    }
    return self;
}

- (NSInteger)allocateID
{
    NSInteger anID = 0;
    //NSLog(@"ID pool before allocation is: %@", freedIDs);
    if ([freedIDs count]) 
    {
        anID = [[freedIDs objectAtIndex:0] integerValue];
        [freedIDs removeObjectAtIndex:0];
    }
    else
    {
        anID = self.position++;
    }
#if SCTestAllocatedNodeIDs
    [self.allocatedIDs addObject:[NSNumber numberWithInteger:anID]];
#endif
    //NSLog(@"%@ Allocating %i", self.name, anID);
    //NSLog(@"ID pool after allocation is: %@", freedIDs);
    return anID;
}

- (void)freeID:(NSInteger)anID
{
    //NSLog(@"%@ Freeing %i", self.name, anID);
    NSNumber *freedID = [NSNumber numberWithInteger:anID];
    NSAssert3(![self.freedIDs containsObject:freedID], @"Double free of an ID! Pool '%@' already contains ID %@", self.name, freedID, self.freedIDs);
    [self.freedIDs addObject:freedID];
#if SCTestAllocatedNodeIDs
    [self.allocatedIDs removeObject:freedID];
#endif
}

@end
