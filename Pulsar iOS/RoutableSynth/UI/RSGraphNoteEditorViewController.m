//
//  RSGraphNoteEditorViewController.m
//  Artikulator
//
//  Created by Luke Iannini on 9/6/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "RSGraphNoteEditorViewController.h"

@implementation RSGraphNoteEditorViewController
@synthesize textView;
@synthesize delegate;

+ (RSGraphNoteEditorViewController *)graphNoteEditorViewControllerWithDelegate:(id <RSGraphNoteEditorViewControllerDelegate>)delegate
{
    RSGraphNoteEditorViewController *editor = [[self alloc] initWithNibName:nil bundle:nil];
    editor.delegate = delegate;
    return editor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.delegate noteEditorWillDismiss:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
