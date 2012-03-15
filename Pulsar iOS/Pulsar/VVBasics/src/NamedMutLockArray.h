#import "VVBasicMacros.h"
#import "MutLockArray.h"




/*
	//	only difference between this and MutLockArray is the "name" variable.
*/




@interface NamedMutLockArray : MutLockArray {
	NSString		*name;
}

+ (id) arrayWithCapacity:(int)c;
+ (id) create;

- (NSComparisonResult) nameCompare:(NamedMutLockArray *)comp;

@property (weak, readwrite) NSString *name;

@end
