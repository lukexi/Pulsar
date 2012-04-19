//
//  NSObject+BlockRecognition.h
//  Pulsar
//
//  Created by Luke Iannini on 4/4/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BlockRecognition)

- (id)ps_value;
- (BOOL)ps_isBlock;
- (NSSet *)ps_superclasses;

@end
