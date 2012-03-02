//
//  SCRoutableSynthEditorViewController.h
//  Artikulator
//
//  Created by Luke Iannini on 8/30/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "RSGraphListViewController.h"

@class RSGraphEditorViewController, RSGraph, NKNodeCanvasView;
@protocol RSGraphEditorViewControllerDelegate <NSObject>

- (void)routableSynthEditorDidFinish:(RSGraphEditorViewController *)aRoutableSynthEditor;

@end

@interface RSGraphEditorViewController : UIViewController <RSGraphListViewControllerDelegate>

+ (id)routableSynthEditorViewControllerWithDelegate:(id <RSGraphEditorViewControllerDelegate>)delegate;

@property (nonatomic, weak) id <RSGraphEditorViewControllerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet NKNodeCanvasView *nodeCanvasView; 
@property (nonatomic, strong) IBOutlet UITextField *titleField;

@property (nonatomic, strong) RSGraph *currentGraph;

- (IBAction)loadGraphAction:(id)sender;
- (IBAction)addNodeAction:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)editNotesAction:(id)sender;

- (void)loadGraph:(RSGraph *)graph;

- (void)save;

// For Subclasses
- (void)applyInitialArgumentsToPreviewGraph;

@end
