//
//  PSStream.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSPattern;
@interface PSStream : NSObject

+ (PSStream *)streamWithPattern:(PSPattern *)pattern;

- (id)next;

@end
