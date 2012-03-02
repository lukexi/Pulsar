//
//  SCIDAllocator.h
//  Artikulator
//
//  Created by Luke Iannini on 9/18/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCTestAllocatedNodeIDs 0

@interface SCIDAllocator : NSObject

+ (id)IDAllocatorStartingAt:(NSInteger)position;

- (NSInteger)allocateID;
- (void)freeID:(NSInteger)anID;

@property (nonatomic, strong) NSString *name;

#if SCTestAllocatedNodeIDs
@property (nonatomic, strong) NSMutableArray *allocatedIDs;
#endif

@end
