//
//  SCOSCOutPort.h
//  Artikulator
//
//  Created by Luke Iannini on 8/20/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "VVOSC.h"

@interface SCOSCOutPort : OSCOutPort

@property (nonatomic, readonly) int sock;

@end
