// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSSynthDef.m instead.

#import "_RSSynthDef.h"

@implementation RSSynthDefID
@end

@implementation _RSSynthDef

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSSynthDef" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSSynthDef";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSSynthDef" inManagedObjectContext:moc_];
}

- (RSSynthDefID*)objectID {
	return (RSSynthDefID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"outputRateIntegerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"outputRateInteger"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic outputRateInteger;



- (int)outputRateIntegerValue {
	NSNumber *result = [self outputRateInteger];
	return [result intValue];
}

- (void)setOutputRateIntegerValue:(int)value_ {
	[self setOutputRateInteger:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOutputRateIntegerValue {
	NSNumber *result = [self primitiveOutputRateInteger];
	return [result intValue];
}

- (void)setPrimitiveOutputRateIntegerValue:(int)value_ {
	[self setPrimitiveOutputRateInteger:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic nodes;

	
- (NSMutableSet*)nodesSet {
	[self willAccessValueForKey:@"nodes"];
	NSMutableSet *result = [self mutableSetValueForKey:@"nodes"];
	[self didAccessValueForKey:@"nodes"];
	return result;
}
	

@dynamic controls;

	
- (NSMutableSet*)controlsSet {
	[self willAccessValueForKey:@"controls"];
	NSMutableSet *result = [self mutableSetValueForKey:@"controls"];
	[self didAccessValueForKey:@"controls"];
	return result;
}
	





@end
