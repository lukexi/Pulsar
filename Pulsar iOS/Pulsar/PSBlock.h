//
//  PSBlock.h
//  Pulsar
//
//  Created by Luke Iannini on 4/6/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^PSEventTransformerBlock)(NSDictionary *event);

@interface PSBlock : NSObject

+ (PSBlock *)block:(PSEventTransformerBlock)block;

- (id)evaluate:(NSDictionary *)event;

@end
