//
//  RTFilterPattern.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTPattern.h"

@interface RTFilterPattern : RTPattern

@property (nonatomic, strong) RTPattern *pattern;

@end

@interface RTPn : RTFilterPattern

+ (RTPn *)PnWithPattern:(RTPattern *)pattern repeats:(id)repeats;
@property (nonatomic, strong) id repeats;

@end

@interface RTPStutter : RTFilterPattern

+ (RTPStutter *)PStutterWithPattern:(RTPattern *)pattern n:(id)n;
@property (nonatomic, strong) id n;

@end