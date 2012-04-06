//
//  PSPatternables.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSPattern.h"

@interface NSObject (Patternable) <PSPatternable>

@end

@interface NSArray (Patternable) <PSPatternable>

@end

@interface NSOrderedSet (Patternable) <PSPatternable>

@end

@interface NSSet (Patternable) <PSPatternable>

@end