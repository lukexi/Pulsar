//
//  Pulsar.m
//  Pulsar
//
//  Created by Luke Iannini on 12/14/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "Pulsar.h"

@interface Pulsar ()
{
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation Pulsar
@synthesize persistentStoreCoordinator, managedObjectModel, managedObjectContext;

+ (Pulsar *)sharedPulsar
{
    static Pulsar *sharedPulsar;
    if (!sharedPulsar) 
    {
        sharedPulsar = [[self alloc] init];
    }
    return sharedPulsar;
}

- (RSGraph *)graph
{
#warning should put this in a temporary inmemory context and add API for switching between temporary and persistent
    return [NSEntityDescription insertNewObjectForEntityForName:@"RSGraph" 
                                         inManagedObjectContext:self.managedObjectContext];
}

- (RSGraph *)graphNamed:(NSString *)name creation:(RSGraphCreationBlock)creationBlock
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RSGraph"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results) 
    {
        NSLog(@"Error fetching graph %@ in Pulsar: %@", name, error);
    }
    RSGraph *graph = [results count] ? [results objectAtIndex:0] : nil;
    if (!graph) 
    {
        NSLog(@"Creating graph: %@", name);
        graph = [NSEntityDescription insertNewObjectForEntityForName:@"RSGraph" 
                                              inManagedObjectContext:self.managedObjectContext];
        graph.name = name;
        creationBlock(graph);
    }
    return graph;
}

- (RSSynthDef *)synthDefNamed:(NSString *)name
{
    return [RSSynthDef synthDefNamed:name inContext:self.managedObjectContext];
}

- (id)init 
{
    self = [super init];
    if (self) 
    {
        [SCServer sharedServer]; // Boots SCSynth
        [RSSynthDef updateDefsInContext:self.managedObjectContext];
    }
    return self;
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Pulsar" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Pulsar.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                  [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeURL 
                                                        options:options 
                                                          error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                      configuration:nil 
                                                                URL:storeURL 
                                                            options:options 
                                                              error:&error])
        {
            NSLog(@"Unresolved error setting up Pulsar PersistentStoreCoordinator %@, %@", 
                  error, [error userInfo]);
            abort();
        }
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
