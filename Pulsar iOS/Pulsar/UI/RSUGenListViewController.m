//
//  SCPulsarUGenListViewController.m
//  Artikulator
//
//  Created by Luke Iannini on 8/31/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "RSUGenListViewController.h"
#import "RSSynthDef.h"

@interface RSUGenListViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation RSUGenListViewController
@synthesize delegate;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

+ (id)UGenListViewControllerWithDelegate:(id <RSUGenListViewControllerDelegate>)delegate 
                                 context:(NSManagedObjectContext *)context
{
    RSUGenListViewController *listViewController = [[self alloc] initWithStyle:UITableViewStylePlain];
    listViewController.delegate = delegate;
    listViewController.managedObjectContext = context;
    return listViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.contentSizeForViewInPopover = CGSizeMake(320, 400);
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
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if (!success) 
    {
        NSLog(@"Error fetching: %@", error);
    }
    [self.tableView reloadData];
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
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RSSynthDef *synthDef = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = synthDef.name;
    cell.detailTextLabel.text = synthDef.outputRate == SCSynthAudioRate ? @"Audio Rate" : @"Control Rate";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSynthDef *synthDef = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate UGenList:self didSelectUGen:synthDef];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (!fetchedResultsController) 
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [RSSynthDef entityInManagedObjectContext:context];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

@end
