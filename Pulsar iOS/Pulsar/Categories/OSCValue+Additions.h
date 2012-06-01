//
//  OSCValue+Additions.h
//  Artikulator
//
//  Created by Luke Iannini on 8/20/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "VVOSC.h"



@interface OSCValue (OSCValue_Additions)

+ (OSCValue *)sc_valueWithObject:(id)object;
- (id)sc_objectValue;

- (NSString *)sc_simpleDescription;

@end
