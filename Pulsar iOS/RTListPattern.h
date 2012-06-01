//
//  RTListPattern.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTPattern.h"

@interface RTListPattern : RTPattern

+ (id)listPatternWithList:(NSArray *)list repeats:(id)repeats;

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) id repeats;

@end

@interface RTPSeq : RTListPattern
+ (id)PSeqWithList:(NSArray *)list repeats:(id)repeats;
+ (id)PSeqWithList:(NSArray *)list repeats:(id)repeats offset:(id)offset;

@property (nonatomic, strong) id offset;

@end

@interface RTPShuf : RTListPattern

+ (id)PShufWithList:(NSArray *)list repeats:(id)repeats;

@end

@interface RTPRand : RTListPattern

+ (id)PRandWithList:(NSArray *)list repeats:(id)repeats;

@end