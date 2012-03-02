// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSNode.m instead.

#import "_RSNode.h"

@implementation RSNodeID
@end

@implementation _RSNode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSNode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSNode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSNode" inManagedObjectContext:moc_];
}

- (RSNodeID*)objectID {
	return (RSNodeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"xValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"x"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"yValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"y"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic x;



- (float)xValue {
	NSNumber *result = [self x];
	return [result floatValue];
}

- (void)setXValue:(float)value_ {
	[self setX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveXValue {
	NSNumber *result = [self primitiveX];
	return [result floatValue];
}

- (void)setPrimitiveXValue:(float)value_ {
	[self setPrimitiveX:[NSNumber numberWithFloat:value_]];
}





@dynamic y;



- (float)yValue {
	NSNumber *result = [self y];
	return [result floatValue];
}

- (void)setYValue:(float)value_ {
	[self setY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveYValue {
	NSNumber *result = [self primitiveY];
	return [result floatValue];
}

- (void)setPrimitiveYValue:(float)value_ {
	[self setPrimitiveY:[NSNumber numberWithFloat:value_]];
}





@dynamic nodeID;






@dynamic inputs;

	
- (NSMutableSet*)inputsSet {
	[self willAccessValueForKey:@"inputs"];
	NSMutableSet *result = [self mutableSetValueForKey:@"inputs"];
	[self didAccessValueForKey:@"inputs"];
	return result;
}
	

@dynamic outWires;

	
- (NSMutableSet*)outWiresSet {
	[self willAccessValueForKey:@"outWires"];
	NSMutableSet *result = [self mutableSetValueForKey:@"outWires"];
	[self didAccessValueForKey:@"outWires"];
	return result;
}
	

@dynamic synthDef;

	

@dynamic graphAsCompletion;

	

@dynamic graph;

	





@end
