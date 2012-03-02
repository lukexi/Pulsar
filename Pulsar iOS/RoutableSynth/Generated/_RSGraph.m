// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSGraph.m instead.

#import "_RSGraph.h"

@implementation RSGraphID
@end

@implementation _RSGraph

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSGraph" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSGraph";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSGraph" inManagedObjectContext:moc_];
}

- (RSGraphID*)objectID {
	return (RSGraphID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic notes;






@dynamic name;






@dynamic outNode;

	

@dynamic nodes;

	
- (NSMutableSet*)nodesSet {
	[self willAccessValueForKey:@"nodes"];
	NSMutableSet *result = [self mutableSetValueForKey:@"nodes"];
	[self didAccessValueForKey:@"nodes"];
	return result;
}
	

@dynamic completionNode;

	





@end
