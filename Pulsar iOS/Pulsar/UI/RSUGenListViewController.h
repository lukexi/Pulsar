//
//  SCPulsarUGenListViewController.h
//  Artikulator
//
//  Created by Luke Iannini on 8/31/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSynthDef.h"

@class RSUGenListViewController;
@protocol RSUGenListViewControllerDelegate <NSObject>

- (void)UGenList:(RSUGenListViewController *)listViewController didSelectUGen:(RSSynthDef *)synthDef;

@end

@interface RSUGenListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

+ (id)UGenListViewControllerWithDelegate:(id <RSUGenListViewControllerDelegate>)delegate 
                                 context:(NSManagedObjectContext *)context;

@property (nonatomic, weak) id <RSUGenListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
