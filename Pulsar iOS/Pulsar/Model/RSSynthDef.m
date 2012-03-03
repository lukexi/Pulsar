#import "RSSynthDef.h"
#import "RSSynthDefControl.h"

@interface RSSynthDef ()

+ (NSMutableDictionary *)synthDefCacheForContext:(NSManagedObjectContext *)context;

@end

@implementation RSSynthDef

+ (RSSynthDef *)synthDefNamed:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    RSSynthDef *cachedSynthDef = [[self synthDefCacheForContext:context] objectForKey:name];
    if (cachedSynthDef) 
    {
        return cachedSynthDef;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [RSSynthDef entityInManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSError *error = nil;
    NSArray *defs = [context executeFetchRequest:request error:&error];
    if (!defs || [defs count] == 0) 
    {
        NSLog(@"Error fetching synthdef '%@' (synthdefs found: %i): %@", name, [defs count], error);
        return nil;
    }
    RSSynthDef *synthDef = [defs objectAtIndex:0];
    [[self synthDefCacheForContext:context] setObject:synthDef forKey:name];
    return synthDef;
}

- (SCSynthRate)outputRate
{
    return self.outputRateIntegerValue;
}

static NSString *RSSynthDefCacheKey = @"RSSynthDefCacheKey";
+ (NSMutableDictionary *)synthDefCacheForContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *synthDefCache = [[context userInfo] objectForKey:RSSynthDefCacheKey];
    if (!synthDefCache) 
    {
        synthDefCache = [NSMutableDictionary dictionary];
        [[context userInfo] setObject:synthDefCache forKey:RSSynthDefCacheKey];
    }
    return synthDefCache;
}

@end

@interface RSSynthDef (LibraryUpdatingPrivate)

- (void)updateControlsFromMetadatum:(NSDictionary *)metadatum;

@end


@implementation RSSynthDef (LibraryUpdating)

+ (void)updateDefsInContext:(NSManagedObjectContext *)context
{
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"PulsarMetadata" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:path];
    NSError *error;
    NSArray *metadata = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!metadata)
    {
        NSLog(@"Error loading PulsarMetadata.json! %@", error);
        return;
    }
    
    NSDictionary *synthDefsByName = [self synthDefsByNameInContext:context];
    
    NSMutableArray *remainingSynthDefs = [[synthDefsByName allValues] mutableCopy];
    
    for (NSDictionary *metadatum in metadata)
    {
        NSString *defName = [metadatum objectForKey:@"defName"];
        
        RSSynthDef *synthDef = [synthDefsByName objectForKey:defName];
        if (synthDef) 
        {
            [remainingSynthDefs removeObject:synthDef];
        }
        else
        {
            synthDef = [RSSynthDef insertInManagedObjectContext:context];
            synthDef.name = defName;            
        }
        
        synthDef.outputRateIntegerValue = [[metadatum objectForKey:@"outputRate"] isEqual:@"control"] ? SCSynthControlRate : SCSynthAudioRate;
        
        [synthDef updateControlsFromMetadatum:metadatum];
        
        [[self synthDefCacheForContext:context] setObject:synthDef forKey:defName];
    }
    
    for (RSSynthDef *notFoundSynthDef in remainingSynthDefs) 
    {
        [context deleteObject:notFoundSynthDef];
    }
    
    error = nil;
    BOOL success = [context save:&error];
    if (!success) 
    {
        NSLog(@"Error saving synthDef update: %@", error);
    }
}



- (NSDictionary *)controlsByName
{
    NSMutableDictionary *controlsByName = [NSMutableDictionary dictionary];
    for (RSSynthDefControl *control in self.controls) 
    {
        [controlsByName setObject:control forKey:control.name];
    }
    return controlsByName;
}

+ (NSDictionary *)synthDefsByNameInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [RSSynthDef entityInManagedObjectContext:context];
    
    NSError *error = nil;
    NSArray *synthDefs = [context executeFetchRequest:request error:&error];
    if (!synthDefs) 
    {
        NSLog(@"Error fetching exisiting synthDefs while updating: %@", error);
    }
    
    NSMutableDictionary *synthDefsByName = [NSMutableDictionary dictionaryWithCapacity:[synthDefs count]];
    for (RSSynthDef *synthDef in synthDefs) 
    {
        [synthDefsByName setObject:synthDef forKey:synthDef.name];
    }
    return synthDefsByName;
}

@end

@implementation RSSynthDef (LibraryUpdatingPrivate)

- (void)updateControlsFromMetadatum:(NSDictionary *)metadatum
{
    // Update controls
    NSDictionary *controlsByName = [self controlsByName];
    
    NSArray *controlNames = [metadatum objectForKey:@"controlNames"];
    NSArray *controlDefaults = [metadatum objectForKey:@"controlDefaults"];
    NSArray *controlRanges = [metadatum objectForKey:@"controlRanges"];
    
    NSUInteger index = 0;
    for (NSString *controlName in controlNames) 
    {
        NSArray *rangeValues = [controlRanges objectAtIndex:index];
        NSNumber *defaultValue = [controlDefaults objectAtIndex:index];
        
        RSSynthDefControl *control = [controlsByName objectForKey:controlName];
        if (!control) 
        {
            control = [RSSynthDefControl insertInManagedObjectContext:self.managedObjectContext];
            control.name = controlName;
            control.synthDef = self;
        }
        
        control.rateIntegerValue = [controlName hasPrefix:@"a_"] ? SCSynthAudioRate : SCSynthControlRate;
        control.defaultValue = defaultValue;
        
        // Set "Warps" for nice 0-1 scaling
        if ([rangeValues count] == 4)
        {
            control.rangeLow = [rangeValues objectAtIndex:0];
            control.rangeHigh = [rangeValues objectAtIndex:1];
            control.warpSpecifier = [rangeValues objectAtIndex:2];
            control.units = [rangeValues objectAtIndex:3];
        }
        else
        {
            control.rangeLowValue = 0;
            control.rangeHighValue = 0;
            control.warpSpecifier = @"lin";
            control.units = @"";
        }
        
        index++;
    }
}

@end
