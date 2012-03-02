#import "RSSynthDefControl.h"

@implementation RSSynthDefControl
@synthesize spec;


- (SCSynthRate)rate
{
    return self.rateIntegerValue;
}

- (SCControlSpec *)spec
{
    if (!spec) 
    {
        spec = [SCControlSpec controlSpecWithMin:self.rangeLowValue 
                                             max:self.rangeHighValue 
                                   warpSpecifier:self.warpSpecifier 
                                           units:self.units];
    }
    return spec;
}

@end
