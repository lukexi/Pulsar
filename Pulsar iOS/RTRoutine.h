//
//  RTRoutine.h
//  Routine
//
//  Created by Luke Iannini on 5/30/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTStream.h"
#import "NSNumber+RTDo.h"
@interface RTRoutine : RTStream

+ (RTRoutine *)routineWithBlock:(RTRoutineBlock)block;

@end

/* USAGE
 NSDate *date = [NSDate date];
 RTRoutine *routine = [RTRoutine routineWithBlock:^(RTYieldBlock yield) {
     NSLog(@"Poops");
     yield(@5);
     NSLog(@"Blargh");
     yield(@6);
     NSLog(@"Whammo");
     yield(@7);
     NSLog(@"Cheese poops");
     yield(@8);
     NSLog(@"Oh");
     NSLog(@"Yeah");
     yield(@9);
 }];
 NSLog(@"Next! %@", [routine next]);
 NSLog(@"'BOUT TIME TO CALL NEXT");
 NSLog(@"Next! %@", [routine next]);
 NSLog(@"'BOUT TIME TO CALL NEXT");
 NSLog(@"Next! %@", [routine next]);
 NSLog(@"'BOUT TIME TO CALL NEXT");
 NSLog(@"Next! %@", [routine next]);
 NSLog(@"'BOUT TIME TO CALL NEXT");
 NSLog(@"Next! %@", [routine next]);
 NSLog(@"%f", [date timeIntervalSinceNow]);
 */
