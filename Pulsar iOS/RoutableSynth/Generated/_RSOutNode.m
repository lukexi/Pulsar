// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSOutNode.m instead.

#import "_RSOutNode.h"

@implementation RSOutNodeID
@end

@implementation _RSOutNode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RSOutNode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RSOutNode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RSOutNode" inManagedObjectContext:moc_];
}

- (RSOutNodeID*)objectID {
	return (RSOutNodeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic graphAsOut;

	





@end
