// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSInput.m instead.

#import "_RSInput.h"

@implementation RSInputID
@end

@implementation _RSInput

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSInput" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSInput";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSInput" inManagedObjectContext:moc_];
}

- (RSInputID*)objectID {
	return (RSInputID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"centerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"center"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modDepthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modDepth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic center;



- (float)centerValue {
	NSNumber *result = [self center];
	return [result floatValue];
}

- (void)setCenterValue:(float)value_ {
	[self setCenter:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveCenterValue {
	NSNumber *result = [self primitiveCenter];
	return [result floatValue];
}

- (void)setPrimitiveCenterValue:(float)value_ {
	[self setPrimitiveCenter:[NSNumber numberWithFloat:value_]];
}





@dynamic modDepth;



- (float)modDepthValue {
	NSNumber *result = [self modDepth];
	return [result floatValue];
}

- (void)setModDepthValue:(float)value_ {
	[self setModDepth:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveModDepthValue {
	NSNumber *result = [self primitiveModDepth];
	return [result floatValue];
}

- (void)setPrimitiveModDepthValue:(float)value_ {
	[self setPrimitiveModDepth:[NSNumber numberWithFloat:value_]];
}





@dynamic synthDefControl;

	

@dynamic wires;

	
- (NSMutableSet*)wiresSet {
	[self willAccessValueForKey:@"wires"];
	NSMutableSet *result = [self mutableSetValueForKey:@"wires"];
	[self didAccessValueForKey:@"wires"];
	return result;
}
	

@dynamic node;

	





@end
