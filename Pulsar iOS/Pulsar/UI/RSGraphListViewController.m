//
//  RSGraphListViewController.m
//  Artikulator
//
//  Created by Luke Iannini on 9/6/11.
//  Copyright 2011 Eeoo. All rights reserved.
//



#import "RSGraphListViewController.h"
#import "RSGraph.h"
#import "RSSynthDef.h"

@interface RSGraphListViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RSGraphListViewController
@synthesize fetchedResultsController;
@synthesize delegate;
@synthesize managedObjectContext;

+ (id)graphListViewControllerWithDelegate:(id <RSGraphListViewControllerDelegate>)delegate
                                  context:(NSManagedObjectContext *)context
                          inNavController:(BOOL)inNavController
{
    RSGraphListViewController *graphList = [[self alloc] initWithStyle:UITableViewStylePlain];
    graphList.delegate = delegate;
    graphList.managedObjectContext = context;
    if (inNavController) 
    {
        return [[UINavigationController alloc] initWithRootViewController:graphList];
    }
    
    return graphList;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = @"Graphs";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if (!success) 
    {
        NSLog(@"Error fetching: %@", error);
    }
    [self.tableView reloadData];
}

- (IBAction)addAction:(id)sender
{
    static NSInteger newGraphsThisSession = 1;
    RSGraph *newGraph = [RSGraph insertInManagedObjectContext:self.managedObjectContext];
    newGraph.name = [NSString stringWithFormat:@"New Graph %i", newGraphsThisSession++];
    [self.delegate graphList:self didCreateGraph:newGraph];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RSGraph *graph = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = graph.name;
    cell.detailTextLabel.text = [[[graph.nodes valueForKeyPath:@"synthDef.name"] allObjects] componentsJoinedByString:@", "];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSGraph *graph = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate graphList:self didSelectGraph:graph];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSGraph *graph = nil;
    switch (editingStyle) 
    {
        case UITableViewCellEditingStyleDelete:
            graph = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self.fetchedResultsController.managedObjectContext deleteObject:graph];
            break;
        case UITableViewCellEditingStyleInsert:
            [self addAction:nil];
            break;
        default:
            break;
    }
}

#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (!fetchedResultsController) 
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [RSGraph entityInManagedObjectContext:context];
        NSPredicate *predicate = nil;
        if ([self.delegate respondsToSelector:@selector(predicateForGraphList:)]) 
        {
            predicate = [self.delegate predicateForGraphList:self];
        }
        request.predicate = predicate;
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

@end
