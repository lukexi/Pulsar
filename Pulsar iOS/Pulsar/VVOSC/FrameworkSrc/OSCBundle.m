
#import "OSCBundle.h"
#import "VVBasicMacros.h"

//LXI
#define VV_SECONDS_FROM_NTPEPOCH_TO_1970 2208988800
#define VV_TWO_TO_32 4294967296

@implementation OSCBundle
@synthesize timeStamp;

+ (void) parseRawBuffer:(unsigned char *)b ofMaxLength:(int)l toInPort:(id)p	{
	//NSLog(@"%s",__func__);
	if ((b == nil) || (l == 0) || (p == NULL))
		return;

	//	remember, OSC data is clumped in a minimum of 4 byte groups!
	//	bytes 0-7 consist of '#bundle', and then a null character to make it an even multiple of 4
	//	bytes 8-15 is an 8-byte (64-bit!) time tag which ostensibly applies to the entire bundle
	//	this is followed by the bundle elements.  each element consists of two things:
	//	1)- a 4-byte (32-bit) int.  this is the bundle length.
	//	2)- the bundle itself- the length of the bundle is described by the 4-byte int before it

	int				baseIndex = 16;
	unsigned char	*c = b;
	int				length = 0;

	while (baseIndex < l)	{
		length = (c[baseIndex+3]) + (c[baseIndex+2] << 8) + (c[baseIndex+1] << 16) + (c[baseIndex] << 24);
		baseIndex = baseIndex + 4;
		if (c[baseIndex] == '#')	{
			[OSCBundle
				parseRawBuffer:b+baseIndex
				ofMaxLength:length
				toInPort:p];
		}
		else if (c[baseIndex] == '/')	{
			[OSCMessage
				parseRawBuffer:b+baseIndex
				ofMaxLength:length
				toInPort:p];
		}

		baseIndex = baseIndex + length;
	}
}

+ (id) create	{
	OSCBundle		*returnMe = [[OSCBundle alloc] init];
	if (returnMe == nil)
		return nil;
	return returnMe;
}
+ (id) createWithElement:(id)n	{
	OSCBundle		*returnMe = [[OSCBundle alloc] init];
	if (returnMe == nil)
		return nil;
	if (n != nil)
		[returnMe addElement:n];
	return returnMe;
}
+ (id) createWithElementArray:(id)a	{
	OSCBundle		*returnMe = [[OSCBundle alloc] init];
	if (returnMe == nil)
		return nil;
	if (a != nil)
		[returnMe addElementArray:a];
	return returnMe;
}
- (id) init	{
	if (self = [super init])	{
		elementArray = [NSMutableArray arrayWithCapacity:0];
		return self;
	}
	return nil;
}

- (void) dealloc	{
	VVRELEASE(elementArray);
}

- (void) addElement:(id)n	{
	if (n == nil)
		return;
	if ((![n isKindOfClass:[OSCBundle class]]) && (![n isKindOfClass:[OSCMessage class]]))
		return;
	[elementArray addObject:n];
}
- (void) addElementArray:(NSArray *)a	{
	if ((a==nil) || ([a count]<1))
		return;
	NSEnumerator		*it = [a objectEnumerator];
	id					anObj;
	while (anObj = [it nextObject])	{
		if (([anObj isKindOfClass:[OSCBundle class]]) || ([anObj isKindOfClass:[OSCMessage class]]))	{
			[elementArray addObject:anObj];
		}
	}
}

- (int) bufferLength	{
	//NSLog(@"%s",__func__);
	int				totalSize = 0;
	NSEnumerator	*it;
	id				anObj;

	/*
	a bundle starts off with:
		8 bytes for the '#bundle'
		8 bytes for the timestamp
	*/
	totalSize = 16;

	//	run through my elements, getting their sizes
	it = [elementArray objectEnumerator];
	while (anObj = [it nextObject])	{
		/*
		each element will occupy an amount of space equal to the size of the payload plus
		4 bytes (these 4 bytes are used to store the size of the payload which follows it)
		*/
		totalSize = totalSize + 4 + [anObj bufferLength];
	}

	return totalSize;
}
- (void) writeToBuffer:(unsigned char *)b	{
	if (b == NULL)
		return;
	int				writeOffset;
	int				elementLength;
	UInt32			tmpInt;
	NSEnumerator	*it;
	id				anObj;

	//	write the "#bundle" to the buffer
	strncpy((char *)b, "#bundle", 7);

    // LXI: write the timestamp into the buffer as a big endian unsigned long long
    
    NSTimeInterval timeSinceReferenceDate = [self.timeStamp timeIntervalSince1970];
    
    double seconds = trunc(timeSinceReferenceDate);
    double fractional = timeSinceReferenceDate - seconds;
    
    double secondsSinceEpoch = seconds + VV_SECONDS_FROM_NTPEPOCH_TO_1970;
    double fractionalSeconds = fractional * VV_TWO_TO_32;
    unsigned long long theTimeStamp = ((unsigned long long)secondsSinceEpoch) << 32;
    unsigned long long swappedTimeStamp = NSSwapHostLongLongToBig(theTimeStamp + (unsigned long long)fractionalSeconds);
    memcpy(b+8, &swappedTimeStamp, 8);

	//	adjust the offset to take into account the #bundle and the timestamp
	writeOffset = 16;
	//	run through all the elements in this bundle
	it = [elementArray objectEnumerator];
	while (anObj = [it nextObject])	{
		//	write the message's size to the buffer
		elementLength = [anObj bufferLength];
		tmpInt = htonl(*((UInt32 *)(&elementLength)));
		memcpy(b+writeOffset, &tmpInt, 4);
		//	adjust the write offset to compensate for writing the message size
		writeOffset = writeOffset + 4;
		//	write the message to the buffer
		[anObj writeToBuffer:b+writeOffset];
		//	adjust the write offset to compensate for the data i just wrote to the buffer
		writeOffset = writeOffset + elementLength;
	}
}


@end
