//
//  KNMasterViewController.h
//  KeepANote
//
//  Created by Claire Reynaud on 10/17/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KNMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
