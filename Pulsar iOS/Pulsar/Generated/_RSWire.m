// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSWire.m instead.

#import "_RSWire.h"

@implementation RSWireID
@end

@implementation _RSWire

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSWire" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSWire";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSWire" inManagedObjectContext:moc_];
}

- (RSWireID*)objectID {
	return (RSWireID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"ampValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"amp"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic amp;



- (float)ampValue {
	NSNumber *result = [self amp];
	return [result floatValue];
}

- (void)setAmpValue:(float)value_ {
	[self setAmp:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveAmpValue {
	NSNumber *result = [self primitiveAmp];
	return [result floatValue];
}

- (void)setPrimitiveAmpValue:(float)value_ {
	[self setPrimitiveAmp:[NSNumber numberWithFloat:value_]];
}





@dynamic destinationInput;

	

@dynamic sourceNode;

	





@end
