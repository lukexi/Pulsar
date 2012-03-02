//
//  RSGraphListViewController.h
//  Artikulator
//
//  Created by Luke Iannini on 9/6/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSGraph.h"

@class RSGraphListViewController;
@protocol RSGraphListViewControllerDelegate <NSObject>

- (void)graphList:(RSGraphListViewController *)graphList didSelectGraph:(RSGraph *)graph;
- (void)graphList:(RSGraphListViewController *)graphList didCreateGraph:(RSGraph *)graph;
@optional
// Use to filter the set of RSGraphs you want to make available for editing
- (NSPredicate *)predicateForGraphList:(RSGraphListViewController *)graphList;

@end

@interface RSGraphListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

+ (id)graphListViewControllerWithDelegate:(id <RSGraphListViewControllerDelegate>)delegate
                                  context:(NSManagedObjectContext *)context
                          inNavController:(BOOL)inNavController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <RSGraphListViewControllerDelegate> delegate;

@end
