// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSSynthDefControl.m instead.

#import "_RSSynthDefControl.h"

@implementation RSSynthDefControlID
@end

@implementation _RSSynthDefControl

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSSynthDefControl" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSSynthDefControl";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSSynthDefControl" inManagedObjectContext:moc_];
}

- (RSSynthDefControlID*)objectID {
	return (RSSynthDefControlID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"rateIntegerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rateInteger"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"defaultValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"defaultValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"rangeLowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rangeLow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"rangeHighValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rangeHigh"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic rateInteger;



- (int)rateIntegerValue {
	NSNumber *result = [self rateInteger];
	return [result intValue];
}

- (void)setRateIntegerValue:(int)value_ {
	[self setRateInteger:[NSNumber numberWithInt:value_]];
}

- (int)primitiveRateIntegerValue {
	NSNumber *result = [self primitiveRateInteger];
	return [result intValue];
}

- (void)setPrimitiveRateIntegerValue:(int)value_ {
	[self setPrimitiveRateInteger:[NSNumber numberWithInt:value_]];
}





@dynamic warpSpecifier;






@dynamic name;






@dynamic defaultValue;



- (float)defaultValueValue {
	NSNumber *result = [self defaultValue];
	return [result floatValue];
}

- (void)setDefaultValueValue:(float)value_ {
	[self setDefaultValue:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveDefaultValueValue {
	NSNumber *result = [self primitiveDefaultValue];
	return [result floatValue];
}

- (void)setPrimitiveDefaultValueValue:(float)value_ {
	[self setPrimitiveDefaultValue:[NSNumber numberWithFloat:value_]];
}





@dynamic units;






@dynamic rangeLow;



- (float)rangeLowValue {
	NSNumber *result = [self rangeLow];
	return [result floatValue];
}

- (void)setRangeLowValue:(float)value_ {
	[self setRangeLow:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRangeLowValue {
	NSNumber *result = [self primitiveRangeLow];
	return [result floatValue];
}

- (void)setPrimitiveRangeLowValue:(float)value_ {
	[self setPrimitiveRangeLow:[NSNumber numberWithFloat:value_]];
}





@dynamic rangeHigh;



- (float)rangeHighValue {
	NSNumber *result = [self rangeHigh];
	return [result floatValue];
}

- (void)setRangeHighValue:(float)value_ {
	[self setRangeHigh:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRangeHighValue {
	NSNumber *result = [self primitiveRangeHigh];
	return [result floatValue];
}

- (void)setPrimitiveRangeHighValue:(float)value_ {
	[self setPrimitiveRangeHigh:[NSNumber numberWithFloat:value_]];
}





@dynamic nodeInputs;

	
- (NSMutableSet*)nodeInputsSet {
	[self willAccessValueForKey:@"nodeInputs"];
	NSMutableSet *result = [self mutableSetValueForKey:@"nodeInputs"];
	[self didAccessValueForKey:@"nodeInputs"];
	return result;
}
	

@dynamic synthDef;

	





@end
