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
	
	if ([key isEqualToString:@"centerValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"centerValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modDepthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modDepth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic centerValue;



- (float)centerValueValue {
	NSNumber *result = [self centerValue];
	return [result floatValue];
}

- (void)setCenterValueValue:(float)value_ {
	[self setCenterValue:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveCenterValueValue {
	NSNumber *result = [self primitiveCenterValue];
	return [result floatValue];
}

- (void)setPrimitiveCenterValueValue:(float)value_ {
	[self setPrimitiveCenterValue:[NSNumber numberWithFloat:value_]];
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
