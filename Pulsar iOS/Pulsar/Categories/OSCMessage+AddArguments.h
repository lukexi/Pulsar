//
//  OSCMessage+AddArguments.h
//  Artikulator
//
//  Created by Luke Iannini on 7/4/10.
//  Copyright 2010 P.W. Worm & Co & Sons All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVOSC.h"

@interface OSCMessage (AddArguments)

- (void)addArguments:(NSArray *)arguments;
- (NSString *)OSCString;

- (NSString *)sc_simpleDescription;

@end
