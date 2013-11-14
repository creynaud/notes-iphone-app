//
//  KNDetailViewController.m
//  KeepANote
//
//  Created by Claire Reynaud on 10/17/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import "KNDetailViewController.h"
#import "AFNetworking.h"
#import "KNSync.h"
#import "KNAppDelegate.h"

@interface KNDetailViewController ()
- (void)configureView;
@end

@implementation KNDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_detailItem == nil) {
        self.navigationItem.title = @"New Note";

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
        [self.titleView becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_detailItem != nil) {
        if (![_detailItem.text isEqualToString:self.textView.text] || ![_detailItem.title isEqualToString:self.titleView.text]) {
            _detailItem.title = self.titleView.text;
            _detailItem.text = self.textView.text;
            _detailItem.state = [NSNumber numberWithInteger:KNNoteStateModified];
            _detailItem.date = [NSDate date];
            
            // Save the context.
            NSError *error = nil;
            NSManagedObjectContext *context = ((KNAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KNSync synchronizer] syncWithServer];
            });
        }
    }
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    NSManagedObjectContext *context = ((KNAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    KNNote *newNote = (KNNote *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    
    newNote.uuid = [[NSUUID UUID] UUIDString];
    newNote.title = self.titleView.text;
    newNote.text = self.textView.text;
    newNote.state = [NSNumber numberWithInteger:KNNoteStateModified];
    newNote.date = [NSDate date];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KNSync synchronizer] syncWithServer];
    });
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(KNNote*)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)configureView
{
    if (self.detailItem) {
        self.titleView.text = self.detailItem.title;
        self.textView.text = self.detailItem.text;
    }
}

@end
